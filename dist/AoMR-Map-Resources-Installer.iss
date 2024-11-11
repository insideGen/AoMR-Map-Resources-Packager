#include "lib/command.iss"
#include "lib/components.iss"

#define SteamUserId SteamUserId /* Passed through parameters | ExecPowerShell('(Get-ItemProperty -Path "HKCU:\Software\Valve\Steam").AutoLoginUser') */
#define SteamGameId SteamGameId /* Passed through parameters | 1934680 => Age Of Mythology: Retold */

#define MyAppName "Age Of Mythology: Retold - Map Resources Installer"
#define MyAppVersion "1.0.0.0"
#define MyAppPublisher SteamUserId
#define MyAppURL ""
#define MyAppExeName "AoMR-Map-Resources-Installer"

[Setup]
; NOTE: To generate a new GUID, click Tools | Generate GUID inside the IDE.
AppId={{F17300E3-7250-4AB4-A2C9-EC69333F261F}}
AppName={#MyAppName} - {#SteamUserId}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} - {#SteamUserId}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
VersionInfoVersion={#MyAppVersion}
VersionInfoCopyright={#MyAppPublisher}
AppendDefaultDirName=no
DefaultDirName={localappdata}\{#MyAppExeName}
PrivilegesRequired=lowest
OutputDir={#SourcePath}\build
OutputBaseFilename={#MyAppExeName}-{#SteamUserId}
;SetupIconFile={#SourcePath}\assets\icon.ico
Compression=lzma
SolidCompression=yes
;WizardStyle=modern
DisableWelcomePage=no
DisableReadyPage=yes
Uninstallable=yes
;WizardImageFile={#SourcePath}\assets\welcome-finish-page.bmp
;WizardSmallImageFile={#SourcePath}\assets\header-image.bmp
ShowLanguageDialog=no

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Messages]
WelcomeLabel2=This wizard will help you install a custom map for Age Of Mythology: Retold.

[Types]
Name: "full"; Description: "Complete installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
#expr Components_ListComponents(AddBackslash(SourcePath) + "dist\steam")
#expr Components_ListComponents(AddBackslash(SourcePath) + "dist\user")

[Files]
Source: "{#SourcePath}\command.bat"; DestDir: "{tmp}"; Flags: dontcopy ignoreversion
Source: "{#SourcePath}\command.ps1"; DestDir: "{tmp}"; Flags: dontcopy ignoreversion
#expr Components_ListFiles(AddBackslash(SourcePath) + "dist\steam", AddBackslash("{code:GetGameInstallPath}") + "game")
#expr Components_ListFiles(AddBackslash(SourcePath) + "dist\user", AddBackslash("{code:GetGameUserPath}"))

[Code]
var
  // Pages
  InfoPage: TWizardPage;
  // Variables
  sGameInstallPath: String;
  sGameUserPath: String;
  bGamePathsFound: Boolean;

// Getter
function GetGameInstallPath(Param: String): String;
begin
  Result := sGameInstallPath;
end;

// Getter
function GetGameUserPath(Param: String): String;
begin
  Result := sGameUserPath;
end;

//
// Create InfoPage
//
procedure InitializeInfoPage();
var
  nTopOffset: Integer;
  nHSpacing: Integer;
  nVSpacing: Integer;
  nMaxLabelWidth: Integer;
  nMaxInputHeight: Integer;
  nI: Integer;
  LabelArray: array of TLabel;
  ControlArray: array of TControl;
  // Labels
  SubCaptionLabel: TNewStaticText;
  GameFolderLabel: TLabel;
  UserFolderLabel: TLabel;
  // Edits
  GameFolderEdit: TNewEdit;
  UserFolderEdit: TNewEdit;
begin
  nTopOffset := 30;
  nHSpacing := 10
  nVSpacing := 8;
  nMaxLabelWidth := 0;
  nMaxInputHeight := 0;
  //
  SetArrayLength(LabelArray, 2);
  SetArrayLength(ControlArray, 2);
  //
  InfoPage := CreateCustomPage(wpSelectDir, 'Informations', 'Installation paths');
  //
  SubCaptionLabel := TNewStaticText.Create(InfoPage);
  SubCaptionLabel.Parent := InfoPage.Surface;
  SubCaptionLabel.Caption := 'Installation will take place in the following automatically detected folders:';
  SubCaptionLabel.Left := 0;
  SubCaptionLabel.Top := 0;
  SubCaptionLabel.AutoSize := True;
  //
  GameFolderLabel := TLabel.Create(InfoPage);
  GameFolderLabel.Parent := InfoPage.Surface;
  GameFolderLabel.Caption := 'Game folder:';
  LabelArray[0] := GameFolderLabel;
  //
  GameFolderEdit := TNewEdit.Create(InfoPage);
  GameFolderEdit.Parent := InfoPage.Surface;
  GameFolderEdit.Text := sGameInstallPath;
  GameFolderEdit.ReadOnly := True;
  ControlArray[0] := GameFolderEdit;
  //
  UserFolderLabel := TLabel.Create(InfoPage);
  UserFolderLabel.Parent := InfoPage.Surface;
  UserFolderLabel.Caption := 'User folder:';
  LabelArray[1] := UserFolderLabel;
  //
  UserFolderEdit := TNewEdit.Create(InfoPage);
  UserFolderEdit.Parent := InfoPage.Surface;
  UserFolderEdit.Text := sGameUserPath;
  UserFolderEdit.ReadOnly := True;
  ControlArray[1] := UserFolderEdit;
  //
  for nI := 0 to GetArrayLength(LabelArray) - 1 do
    begin
      LabelArray[nI].AutoSize := True;
      if LabelArray[nI].Width > nMaxLabelWidth then
        nMaxLabelWidth := LabelArray[nI].Width;
      if LabelArray[nI].Height > nMaxInputHeight then
        nMaxInputHeight := LabelArray[nI].Height;
      if ControlArray[nI].Height > nMaxInputHeight then 
        nMaxInputHeight := ControlArray[nI].Height;
    end;
  //
  nMaxInputHeight := 21;
  //
  for nI := 0 to GetArrayLength(LabelArray) - 1 do
    begin
      LabelArray[nI].Left := 0;
      LabelArray[nI].Top := nTopOffset + 3 + nI * (nMaxInputHeight + nVSpacing);
      LabelArray[nI].Width := nMaxLabelWidth;
      LabelArray[nI].Height := nMaxInputHeight;
      LabelArray[nI].Alignment := taRightJustify;
      //
      ControlArray[nI].Left := LabelArray[nI].Width + nHSpacing;
      ControlArray[nI].Top := nTopOffset + nI * (nMaxInputHeight + nVSpacing);
      ControlArray[nI].Width := InfoPage.Surface.Width - ControlArray[nI].Left;
      ControlArray[nI].Height := nMaxInputHeight;
    end;
end;

//
// Valid InfoPage
//
function ValidInfoPage(): Boolean;
var
  bResult: Boolean;
begin
  bResult := True;
  Result := bResult;
end;

function InitializeSetup: Boolean;
var
  nResultCode: Integer;
  asResult: TStrings;
  
begin
  ExtractTemporaryFiles('{tmp}\*');
  
  asResult := ExecAndGetLines('command.bat', 'all {#SteamGameId}', ExpandConstant('{tmp}'), nResultCode);
  if (nResultCode = 0) then
    begin
      // Steam username: asResult[0]
      sGameInstallPath := asResult[1];
      sGameUserPath := asResult[2];
      bGamePathsFound := True;
    end
  else
    begin
      sGameInstallPath := 'Not found';
      sGameUserPath := 'Not found';
      bGamePathsFound := False;
    end;
  
  Result := True;
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
  //
  // Initialize pages
  //
  InitializeInfoPage();
end;

function ShouldSkipPage(PageID: Integer): Boolean;
var
  bResult: Boolean;
begin
  if PageID in [wpWelcome, InfoPage.ID, wpSelectComponents, wpFinished] then
    bResult := False
  else
    bResult := True;
  Log(Format('ShouldSkipPage: %d -> %d', [PageIndexFromID(PageID), bResult]));
  Result := bResult;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  bResult: Boolean;
begin
  case CurPageID of
    InfoPage.ID:
      begin
        bResult := ValidInfoPage();
      end;
  else
    bResult := True;
  end;
  Log(Format('NextButtonClick: %d -> %d', [PageIndexFromID(CurPageID), bResult]));
  Result := bResult;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  case CurPageID of
    InfoPage.ID:
      begin
        if bGamePathsFound then
          Wizardform.NextButton.Enabled := True
        else
          Wizardform.NextButton.Enabled := False;
      end;
    wpReady:
      begin
        WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)
      end;
    wpFinished:
      begin
        WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish)
      end;
    else
      begin
        WizardForm.NextButton.Caption := SetupMessage(msgButtonNext);
        WizardForm.CancelButton.Enabled := True;
      end;
  end;
  Log(Format('CurPageChanged: %d', [PageIndexFromID(CurPageID)]));
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

//function InitializeUninstall(): Boolean;
//begin
//  Result := MsgBox('InitializeUninstall:' #13#13 'Uninstall is initializing. Do you really want to start Uninstall?', mbConfirmation, MB_YESNO) = idYes;
//  if Result = False then
//    MsgBox('InitializeUninstall:' #13#13 'Ok, bye bye.', mbInformation, MB_OK);
//end;

//procedure DeinitializeUninstall();
//begin
//  MsgBox('DeinitializeUninstall:' #13#13 'Bye bye!', mbInformation, MB_OK);
//end;

//procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
//begin
//  case CurUninstallStep of
//    usUninstall:
//      begin
//        MsgBox('CurUninstallStepChanged:' #13#13 'Uninstall is about to start.', mbInformation, MB_OK)
//        // ...insert code to perform pre-uninstall tasks here...
//      end;
//    usPostUninstall:
//      begin
//        MsgBox('CurUninstallStepChanged:' #13#13 'Uninstall just finished.', mbInformation, MB_OK);
//        // ...insert code to perform post-uninstall tasks here...
//      end;
//  end;
//end;

//#expr SaveToFile(AddBackslash(SourcePath) + MyAppExeName + "-Preprocessed.iss")
