// Rubbish Code Generator 0.1 | Mahdi Hezaveh
// First release on 26th, October 2010
//
// Rubbish Engine : Morphine by Holy_Father & Ratter/29A.
// Dis_asm Engine : DeDe by DaFixer.

program rcg_0_1;
{$R res\main.res}
{$APPTYPE CONSOLE}

uses
  windows,
  uRubbishCode in 'units\uRubbishCode.pas',
  uDisAsmTables in 'units\uDisAsmTables.pas',
  uDisAsm in 'units\uDisAsm.pas';

const
  nl = #13#10;
  _asmdb = 'asm db    ';
  _line = 'asm db    $%.2X, $%.2X, $%.2X, $%.2X, $%.2X, $%.2X, $%.2X, $%.2X, $%.2X, $%.2X end; ' + nl;
  _shortline = '$%.2X, ';
  _lastbyte = '$%.2X end;' + nl;

var
  szBuffer: array[0..1000] of Char;
  lpBytes: array[0..9] of dWord;

function IsNumber(S: string): boolean;
var
  i: Integer;
begin
  result := false;
  for i := 1 to Length(S) do
    case S[i] of
      '0'..'9':
        ;
    else
      Exit;
    end;
  result := True;
end;

function IntToStr(cInt: Longint): string;
begin
  Str(cInt, Result);
end;

function StrToInt(cStr: string): Longint;
var
  Code: Integer;
begin
  val(cStr, Result, Code);
  if Code <> 0 then
    Result := 0;
end;

function FileExists(const FileName: string): boolean;
var
  cHandle: THandle;
  FindData: TWin32FindData;
begin
  cHandle := FindFirstFileA(PChar(FileName), FindData);
  result := cHandle <> INVALID_HANDLE_VALUE;
  if result then
  begin
    FindClose(cHandle);
  end;
end;

procedure WriteRubbishBuf(NFile: word; const BufSize: dWord);
var
  hObfFile, hIncFile, hAsmFile: THandle;
  dwFileSize, dwAddress, dwRB: dWord;
  dwTemp, i: dWord;
  dwBufSize: Word;
  DeDe: TDisAsm;
  sInst: string;
  fsize, sizeall, j: integer;
  ptrBuf, AsmBuf: Pointer;
  // ThreadID : THandle;
begin

  for j := 1 to NFile do
  begin

    // 1
    // Generate Rubbish Code
    dwBufSize := BufSize;
    GetMem(ptrBuf, dwBufSize);
    GenerateRubbishCode(ptrBuf, dwBufSize, 0);

    // Save Rubbish Code to "rcm.obf"
    hObfFile := CreateFile(pChar('rcm.obf'), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

    if hObfFile = INVALID_HANDLE_VALUE then
    begin
      exit;
    end;

    SetFilePointer(hObfFile, $0, nil, 0);
    WriteFile(hObfFile, ptrBuf^, dwBufSize, dwTemp, nil);

    // 2
    // Create "rcm_asm.txt"
    hAsmFile := CreateFile(pChar('rcm_asm_' + inttostr(BufSize) + '_' + inttostr(j) + '.txt'), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

    if hAsmFile = INVALID_HANDLE_VALUE then
    begin
      exit;
    end;

    // Disassemble starting ...                         SAL can't be shown !!
    GetMem(AsmBuf, dwBufSize);

    Setfilepointer(hObfFile, $0, nil, FILE_BEGIN);
    ReadFile(hObfFile, AsmBuf^, dwBufSize, dwTemp, nil);

    fsize := 0;
    sizeall := 0;
    szBuffer := '';
    DeDe := TDisASM.Create;
    repeat
      //error := not InstructionInfo(p,fname,fsize);
      sInst := DeDe.GetInstruction(AsmBuf, fsize);
      inc(sizeall, fsize);
      AsmBuf := Pointer(integer(AsmBuf) + fsize);

      lstrcat(szBuffer, PChar(sInst + nl));
      WriteFile(hAsmFile, szBuffer, lstrlen(szBuffer), dwRB, nil);
      szBuffer := '';
    until (sizeall >= BufSize);
    DeDe.Free;

    CloseHandle(hAsmFile);
    CloseHandle(hObfFile);

    // 3
    // Create .inc file(s)
    hIncFile := CreateFile(pChar('obf_' + inttostr(BufSize) + '_' + inttostr(j) + '.inc'), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

    if hIncFile = INVALID_HANDLE_VALUE then
    begin
      exit;
    end;

    dwFileSize := BufSize + 1;
    dwAddress := 0;

    while (dwAddress < dwFileSize - 10) do
    begin
      for i := 0 to 9 do
        lpBytes[i] := BYTE(Pointer(DWORD(ptrBuf) + dwAddress + i)^);

      wvsprintf(szBuffer, _line, @lpBytes);
      WriteFile(hIncFile, szBuffer, lstrlen(szBuffer), dwRB, nil);
      dwAddress := dwAddress + 10;
    end;

    if dwAddress < dwFileSize - 1 then
    begin
      wvsprintf(szBuffer, _asmdb, @dwFileSize);
      WriteFile(hIncFile, szBuffer, lstrlen(szBuffer), dwRB, nil);
    end;

    for i := dwAddress to dwFileSize - 2 do
    begin
      lpBytes[0] := BYTE(Pointer(DWORD(ptrBuf) + i)^);
      if i = dwFileSize - 2 then
        wvsprintf(szBuffer, _lastbyte, @lpBytes[0])
      else
        wvsprintf(szBuffer, _shortline, @lpBytes[0]);

      WriteFile(hIncFile, szBuffer, lstrlen(szBuffer), dwRB, nil);
    end;

    CloseHandle(hIncFile);

    FreeMem(ptrBuf);

  end; // for j

  deletefile('rcm.obf');

end;

var
  sParam1, sParam2: string;

begin
  //{$I obf.inc}

  sParam1 := ParamStr(1);
  sParam2 := ParamStr(2);

  writeln(' ______________________________________________________________________________ ');
  writeln('                   Rubbish Code Generator 0.1 | Mahdi Hezaveh                   ');
  writeln('                               26th, October 2010                               ');
  writeln;
  writeln('  Usage    : rcg.exe [ rubbish buffer size ] [ number of rubbish file ]');
  writeln('  Example  : rcg.exe 739 13');
  writeln;
  writeln('  Note     : rubbish buffer size >= 10 --- number of rubbish file <= 999 & >= 1');
  writeln;
  writeln('  [+] Rubbish Engine : Morphine by Holy_Father & Ratter/29A');
  writeln('  [+] Dis_asm Engine : DeDe by DaFixer');
  writeln(' ______________________________________________________________________________ ');

  if (not (IsNumber(sParam1))) or (not (IsNumber(sParam2))) or (sParam1 = '') or (sParam2 = '') or (strtoint(sParam2) <= 0) or (strtoint(sParam2) > 999) or (strtoint(sParam1) < 10) then
  begin
    writeln('[-] Command line Error ! Application terminated ...');
    exit;
  end;

  WriteRubbishBuf(strtoint(sParam2), strtoint(sParam1));
  writeln('[+] Done ...');

  // CreateThread(nil, 0, @Generate, nil, 0, ThreadID);
end.

