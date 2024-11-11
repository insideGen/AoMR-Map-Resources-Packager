#include "lib/command.iss"

#define SteamGameId "1934680" /* 1934680 => Age Of Mythology: Retold */

#define MyAppName "Age Of Mythology: Retold - Map Resources Packager"
#define MyAppVersion "1.0.0.0"
#define MyAppPublisher "insideGen"
#define MyAppURL ""
#define MyAppExeName "AoMR-Map-Resources-Packager"

[Setup]
; NOTE: To generate a new GUID, click Tools | Generate GUID inside the IDE.
AppId={{765FBD95-8811-4A41-8341-0B9FA836304B}}
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
DisableWelcomePage=no
DisableReadyPage=no
Uninstallable=no
;WizardImageFile={#SourcePath}\assets\welcome-finish-page.bmp
;WizardSmallImageFile={#SourcePath}\assets\header-image.bmp
ShowLanguageDialog=no

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Messages]
WelcomeLabel2=This wizard will help you package a custom map for Age Of Mythology: Retold.

[Files]
Source: "{#SourcePath}lib\*"; DestDir: "{tmp}\lib"; Flags: dontcopy ignoreversion
Source: "{#SourcePath}dist\*"; DestDir: "{tmp}"; Flags: dontcopy ignoreversion

[Code]
var
  // Pages
  InfoPage: TWizardPage;
  // Variables
  sSteamUsername: String;
  sGameInstallPath: String;
  sGameUserPath: String;
  bGamePathsFound: Boolean;

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
  UsernameLabel: TLabel;
  FileInstructionLabel: TNewStaticText;
  FileExampleLabel: TNewStaticText;
  // Edits
  GameFolderEdit: TNewEdit;
  UserFolderEdit: TNewEdit;
  UsernameEdit: TNewEdit;
begin
  nTopOffset := 30;
  nHSpacing := 10
  nVSpacing := 8;
  nMaxLabelWidth := 0;
  nMaxInputHeight := 0;
  //
  SetArrayLength(LabelArray, 3);
  SetArrayLength(ControlArray, 3);
  //
  InfoPage := CreateCustomPage(wpSelectDir, 'Informations', 'Installation paths and Steam username');
  //
  SubCaptionLabel := TNewStaticText.Create(InfoPage);
  SubCaptionLabel.Parent := InfoPage.Surface;
  SubCaptionLabel.Caption := 'The packager will search for resources in the following automatically detected folders:';
  SubCaptionLabel.Left := 0;
  SubCaptionLabel.Top := 0;
  SubCaptionLabel.Width := InfoPage.Surface.Width;
  SubCaptionLabel.AutoSize := True;
  SubCaptionLabel.WordWrap := True;
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
  GameFolderEdit.AutoSelect := False;
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
  GameFolderEdit.AutoSelect := False;
  ControlArray[1] := UserFolderEdit;
  //
  UsernameLabel := TLabel.Create(InfoPage);
  UsernameLabel.Parent := InfoPage.Surface;
  UsernameLabel.Caption := 'Steam username:';
  LabelArray[2] := UsernameLabel;
  //
  UsernameEdit := TNewEdit.Create(InfoPage);
  UsernameEdit.Parent := InfoPage.Surface;
  UsernameEdit.Text := sSteamUsername;
  UsernameEdit.ReadOnly := True;
  GameFolderEdit.AutoSelect := False;
  ControlArray[2] := UsernameEdit;
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
  //
  FileInstructionLabel := TNewStaticText.Create(InfoPage);
  FileInstructionLabel.Parent := InfoPage.Surface;
  FileInstructionLabel.Caption := 'Only files prefixed with your Steam username followed by an underscore will be searched. Remember to name each map and each map resource correctly in the game editor.';
  FileInstructionLabel.Font.Color := clRed;
  FileInstructionLabel.Left := 0;
  FileInstructionLabel.Top := UserFolderEdit.Top + 2 * (15 + nVSpacing);
  FileInstructionLabel.Width := InfoPage.Surface.Width;
  FileInstructionLabel.AutoSize := True;
  FileInstructionLabel.WordWrap := True;
  //
  UsernameLabel.Top := FileInstructionLabel.Top + FileInstructionLabel.Height + 3 + nVSpacing;
  UsernameEdit.Top := FileInstructionLabel.Top + FileInstructionLabel.Height + nVSpacing;
  //
  FileExampleLabel := TNewStaticText.Create(InfoPage);
  FileExampleLabel.Parent := InfoPage.Surface;
  FileExampleLabel.Caption := Format('e.g. %s_myAwesomeMap.mythscn', [sSteamUsername]);
  FileExampleLabel.Left := UsernameEdit.Left;
  FileExampleLabel.Top := UsernameEdit.Top + (nMaxInputHeight + nVSpacing);
  FileExampleLabel.Width := UsernameEdit.Width;
  FileExampleLabel.WordWrap := True;
end;

//
// Valid InfoPage
//
function ValidInfoPage(): Boolean;
var
  ResultCode: Integer;
  UnzipCmd: String;
  IsccExe: String;
  PrePackagerBuildCmd: String;
  PrePackagerExe: String;
  InstallerBuildCmd: String;
  ProgressPage: TOutputMarqueeProgressWizardPage;
  
begin
  // Init variables
  UnzipCmd := ExpandConstant('Expand-Archive -Path "{tmp}\iscc.zip" -DestinationPath "{tmp}\iscc"');
  IsccExe := ExpandConstant('{tmp}\iscc\ISCC.exe');
  PrePackagerBuildCmd := ExpandConstant('/DSteamUserId="'+sSteamUsername+'" /DSteamGameId="{#SteamGameId}" /DGameInstallDir="'+sGameInstallPath+'" /DGameUserDir="'+sGameUserPath+'" "{tmp}\PrePackager.iss"');
  PrePackagerExe := ExpandConstant('{tmp}\build\AoMR-Map-Resources-PrePackager.exe');
  InstallerBuildCmd := ExpandConstant('/O"{src}" /DSteamUserId="'+sSteamUsername+'" /DSteamGameId="{#SteamGameId}" "{tmp}\Installer.iss"');
  
  ProgressPage := CreateOutputMarqueeProgressPage('Resource selection', 'Preparing the resource selection page');
  ProgressPage.Show();
  
  ExecPowerShell(UnzipCmd, ResultCode);
  
  // Compile PrePackager
  if ResultCode = 0 then
    begin
      Log('ISCC.exe ' + PrePackagerBuildCmd);
      if Exec(IsccExe, PrePackagerBuildCmd, ExpandConstant('{tmp}'), SW_HIDE, ewWaitUntilTerminated, ResultCode) then
        if ResultCode = 0 then
            Log('Success')
        else
          Log('Error: ' + IntToStr(ResultCode))
      else
        Log('Error: ' + SysErrorMessage(ResultCode));
    end;
  
  // Execute PrePackager
  if ResultCode = 0 then
    begin
      Log(PrePackagerExe);
      if Exec(PrePackagerExe, '', ExpandConstant('{tmp}'), SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
        if ResultCode = 0 then
            Log('Success')
        else
          Log('Error: ' + IntToStr(ResultCode))
      else
        Log('Error: ' + SysErrorMessage(ResultCode));
    end;
  
  ProgressPage.Hide();
  
  ProgressPage := CreateOutputMarqueeProgressPage('Resource packaging', 'Work in progress');
  ProgressPage.Show();
  
  // Compile Installer
  if ResultCode = 0 then
    begin
      Log('ISCC.exe ' + InstallerBuildCmd);
      if Exec(IsccExe, InstallerBuildCmd, ExpandConstant('{tmp}'), SW_HIDE, ewWaitUntilTerminated, ResultCode) then
        if ResultCode = 0 then
            Log('Success')
        else
          Log('Error: ' + IntToStr(ResultCode))
      else
        Log('Error: ' + SysErrorMessage(ResultCode));
    end;
  
  ProgressPage.Hide();
  
  Result := (ResultCode = 0);
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
      sSteamUsername := asResult[0];
      sGameInstallPath := asResult[1];
      sGameUserPath := asResult[2];
      bGamePathsFound := True;
    end
  else
    begin
      sSteamUsername := 'Not found';
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
  if PageID in [wpWelcome, InfoPage.ID, wpFinished] then
    bResult := False
  else
    bResult := True;
  Log(Format('ShouldSkipPage: %d -> %d', [PageIndexFromID(PageID), bResult]));
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
  end;
  WizardForm.ActiveControl := nil;
  Log(Format('CurPageChanged: %d', [PageIndexFromID(CurPageID)]));
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

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
//var
begin
  Result := '';
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
