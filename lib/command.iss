#define PowerShellExe "powershell.exe"
#define PowerShellCommandParam "-ExecutionPolicy Bypass -Command "

#define ExecPowerShell(str Command) \
  Message(PowerShellExe + " " + PowerShellCommandParam + AddQuotes(Command)), \
  ExecAndGetFirstLine(PowerShellExe, PowerShellCommandParam + AddQuotes(Command))

[Code]
var
  Line: String;
  Lines: TStrings;
  
procedure ExecAndGetFirstLineLog(const S: String; const Error: Boolean; const FirstLine: Boolean);
begin
  if not Error and (Line = '') and (Trim(S) <> '') then
    Line := S; // First non-empty line found, store it
end;

function ExecAndGetFirstLine(const Filename: String; const Params: String; const WorkingDir: String; var ResultCode: Integer): String;
begin
  Line := '';
  ExecAndLogOutput(Filename, Params, WorkingDir, SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode, @ExecAndGetFirstLineLog);
  Result := Line;
end;

procedure ExecAndGetLinesLog(const S: String; const Error: Boolean; const FirstLine: Boolean);
begin
  if not Error and (Trim(S) <> '') then
    Lines.Add(S); // Non-empty line found, store it
end;

function ExecAndGetLines(const Filename: String; const Params: String; const WorkingDir: String; var ResultCode: Integer): TStrings;
begin
  Lines := TStringList.Create();
  ExecAndLogOutput(Filename, Params, WorkingDir, SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode, @ExecAndGetLinesLog);
  Result := Lines;
end;

function ExecPowerShell(const Command: String; var ResultCode: Integer): String;
var
  FullCommand: String;
begin
  FullCommand := '{#PowerShellCommandParam}' + AddQuotes(Command);
  Log('Executing PowerShell command: ' + FullCommand);
  Result := ExecAndGetFirstLine('{#PowerShellExe}', FullCommand, '', ResultCode);
end;

