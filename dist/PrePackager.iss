#include "lib/command.iss"
#include "lib/components.iss"

#define SteamUserId SteamUserId /* Passed through parameters | ExecPowerShell('(Get-ItemProperty -Path "HKCU:\Software\Valve\Steam").AutoLoginUser') */
#define SteamGameId SteamGameId /* Passed through parameters | "1934680" /* 1934680 => Age Of Mythology: Retold */
#define GameInstallDir GameInstallDir /* Passed through parameters | ExecAndGetFirstLine("command.bat", "gamedir " + SteamGameId, AddBackslash(SourcePath) + "dist") */
#define GameUserDir GameUserDir /* Passed through parameters | ExecAndGetFirstLine("command.bat", "userdir " + SteamGameId, AddBackslash(SourcePath) + "dist") */

#define MyAppName "Age Of Mythology: Retold - Map Resources Packager"
#define MyAppVersion "1.0.0.0"
#define MyAppPublisher SteamUserId
#define MyAppURL ""
#define MyAppExeName "AoMR-Map-Resources-PrePackager"

[Setup]
; NOTE: To generate a new GUID, click Tools | Generate GUID inside the IDE.
AppId={{351B76F0-F4C9-493F-917F-43EFFF0D8624}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
VersionInfoVersion={#MyAppVersion}
VersionInfoCopyright={#MyAppPublisher}
AppendDefaultDirName=no
;DefaultDirName={localappdata}\{#MyAppExeName}
DefaultDirName={src}
PrivilegesRequired=lowest
OutputDir={#SourcePath}\build
OutputBaseFilename={#MyAppExeName}
;SetupIconFile={#SourcePath}\assets\icon.ico
Compression=lzma
SolidCompression=yes
;WizardStyle=modern
DisableWelcomePage=yes
DisableReadyPage=yes
Uninstallable=no
;WizardImageFile={#SourcePath}\assets\welcome-finish-page.bmp
;WizardSmallImageFile={#SourcePath}\assets\header-image.bmp
ShowLanguageDialog=no

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Messages]
WelcomeLabel2=This wizard will help you package a custom map for Age Of Mythology: Retold.

[Types]
Name: "full"; Description: "Complete installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
#expr Components_ListComponents(AddBackslash(GameInstallDir) + "game")
#expr Components_ListComponents(AddBackslash(GameUserDir))

[Files]
#expr Components_ListFiles(AddBackslash(GameInstallDir) + "game", AddBackslash(SourcePath) + "dist\steam")
#expr Components_ListFiles(AddBackslash(GameUserDir), AddBackslash(SourcePath) + "dist\user")

[Code]
//var

function InitializeSetup: Boolean;
var
  bResult: Boolean;
begin
  if {#Components_FileFound} = 1 then
    bResult := True
  else
    bResult := False;
  Result := bResult;
end;

procedure InitializeWizard;
var
  nSmallBitmapLeft: Integer;
begin
  //
  // Resize logo top right
  //
  WizardForm.WizardSmallBitmapImage.Stretch := False;
  nSmallBitmapLeft := WizardForm.WizardSmallBitmapImage.Bitmap.Width - WizardForm.WizardSmallBitmapImage.Width;
  WizardForm.WizardSmallBitmapImage.Left := WizardForm.WizardSmallBitmapImage.Left - nSmallBitmapLeft;
  WizardForm.WizardSmallBitmapImage.Width := WizardForm.WizardSmallBitmapImage.Width + nSmallBitmapLeft;
  WizardForm.PageNameLabel.Width := WizardForm.PageNameLabel.Width - nSmallBitmapLeft;
  WizardForm.PageDescriptionLabel.Width := WizardForm.PageDescriptionLabel.Width - nSmallBitmapLeft;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
var
  bResult: Boolean;
begin
  if PageID in [wpSelectComponents] then
    bResult := False
  else
    bResult := True;
  Log(Format('ShouldSkipPage: %d -> %d', [PageIndexFromID(PageID), bResult]));
  Result := bResult;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  WizardForm.ActiveControl := nil;
  Log(Format('CurPageChanged: %d', [PageIndexFromID(CurPageID)]));
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  bResult: Boolean;
begin
  bResult := True;
  Log(Format('NextButtonClick: %d -> %d', [PageIndexFromID(CurPageID), bResult]));
  Result := bResult;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  sCurStep: String;
begin
  case CurStep of
    ssInstall:
      begin
        sCurStep := 'Install';
      end;
    ssPostInstall:
      begin
        sCurStep := 'PostInstall';
      end;
    ssDone:
      begin
        sCurStep := 'Done';
      end;
  end;
  Log(Format('CurStepChanged: %s', [sCurStep]));
end;

//#expr SaveToFile(AddBackslash(SourcePath) + MyAppExeName + "-Preprocessed.iss")
