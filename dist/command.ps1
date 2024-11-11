param (
    [Parameter(Position = 1)]
    [string] $Command = "",

    [Parameter(Position = 2)]
    [string] $GameNameOrId = ""
)

$SteamRegKey = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam"
$UserName = $SteamRegKey.AutoLoginUser

if ($Command -eq "username") {
    Write-Output "$UserName"
    exit 0
}

$GameNameOrId = $GameNameOrId.Trim()

[bool] $IsGameId = $false
if ($GameNameOrId -match "^\d+$") {
    $IsGameId = $true
}

$LibraryFoldersFile = Join-Path -Path $SteamRegKey.SteamPath -ChildPath "steamapps\libraryfolders.vdf"

$LibraryPaths = @()
if (Test-Path $LibraryFoldersFile) {
    $LibraryFoldersContent = Get-Content $LibraryFoldersFile -Raw
    $lines = $LibraryFoldersContent -split "\r?\n"
    foreach ($line in $lines) {
        if ($line -match '^\s*"path"\s*"(.+)"') {
            $path = $Matches[1]
            if ($path -notmatch "totalsize") {
                $LibraryPaths += $path -replace "\\\\", "\"
            }
        }
    }
}

# $GamePaths = @()
# foreach ($libPath in $LibraryPaths) {
#     $AppManifestPaths = Get-ChildItem -Path "$libPath\steamapps" -Filter "appmanifest_*.acf" -File
#     foreach ($AppManifestPath in $AppManifestPaths) {
#         $AppID = $AppManifestPath.Name -replace "\D", ""
#         $ManifestContent = Get-Content $AppManifestPath.FullName -Raw
#         if ($ManifestContent -match '"installdir"\s*"(.*?)"') {
#             $GameSubDir = $Matches[1]
#             $GameInstallDir = Join-Path -Path $libPath -ChildPath "steamapps\common\$GameSubDir"
#             $GamePaths += $GameInstallDir -replace "\\\\", "\"
#             Write-Output "$GameInstallDir"
#         }
#     }
# }

foreach ($libPath in $LibraryPaths) {
    $AppManifestPaths = Get-ChildItem -Path "$libPath\steamapps" -Filter "appmanifest_*.acf" -File
    foreach ($AppManifestPath in $AppManifestPaths) {
        $AppID = $AppManifestPath.Name -replace "\D", ""
        $ManifestContent = Get-Content $AppManifestPath.FullName -Raw
        if ($ManifestContent -match '"installdir"\s*"(.*?)"') {
            $GameSubDir = $Matches[1]
            if (($IsGameId -and $AppID -eq $GameNameOrId) -or $GameSubDir -eq $GameNameOrId) {
                if ($ManifestContent -match '"LastOwner"\s*"(.*?)"') {
                    $LastOwner = $Matches[1]

                    $GameInstallDir = Join-Path -Path $libPath -ChildPath "steamapps\common\$GameSubDir"
                    $GameInstallDir = $GameInstallDir -replace "\\\\", "\"

                    $GameUserDir = Join-Path -Path $env:USERPROFILE -ChildPath "Games\$GameSubDir\$LastOwner"
                    $GameUserDir = $GameUserDir -replace "\\\\", "\"

                    if ($Command -eq "installdir") {
                        Write-Output "$GameInstallDir"
                        exit 0
                    }

                    if ($Command -eq "userdir") {
                        Write-Output "$GameUserDir"
                        exit 0
                    }

                    Write-Output "$UserName"
                    Write-Output "$GameInstallDir"
                    Write-Output "$GameUserDir"
                    exit 0

                    # if ((Test-Path $GameInstallDir) -and (Test-Path $GameUserDir)) {

                    #     $GameInfoFile = ".\gameinfo.txt"
                    #     Remove-Item "$GameInfoFile" -ErrorAction Ignore
                    #     Add-Content -Path "$GameInfoFile" -Value "$GameInstallDir"
                    #     $GameFiles = Get-ChildItem -Path $GameInstallDir -Recurse -Filter "$($UserName)_*"
                    #     foreach ($filePath in $GameFiles) {
                    #         $RelativePath = Resolve-Path -Relative -Path $filePath -RelativeBasePath $GameInstallDir
                    #         Add-Content -Path "$GameInfoFile" -Value "$RelativePath"
                    #     }

                    #     $UserInfoFile = ".\userinfo.txt"
                    #     Remove-Item "$UserInfoFile" -ErrorAction Ignore
                    #     Add-Content -Path "$UserInfoFile" -Value "$GameUserDir"
                    #     $UserFiles = Get-ChildItem -Path $GameUserDir -Recurse -Filter "$($UserName)_*"
                    #     foreach ($filePath in $UserFiles) {
                    #         $RelativePath = Resolve-Path -Relative -Path $filePath -RelativeBasePath $GameUserDir
                    #         Add-Content -Path "$UserInfoFile" -Value "$RelativePath"
                    #     }

                    #     exit 0
                    # }
                }
            }
        }
    }
}

exit 1
