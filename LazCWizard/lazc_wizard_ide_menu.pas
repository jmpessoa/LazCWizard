unit lazc_wizard_ide_menu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Dialogs, Interfaces, Clipbrd;

procedure Register;

implementation

uses
   {$ifdef unix}BaseUnix,{$endif}
   IDEExternToolIntf, LazIDEIntf, IniFiles, LazFileUtils,
   CompOptsIntf, IDEMsgIntf,
   ProjectIntf, MacroIntf, Controls, LCLType,
   IDECommands, MenuIntf, Process, PackageIntf;


function SplitStr(var theString: string; delimiter: string): string;
var
  i: integer;
begin
  Result:= '';
  if theString <> '' then
  begin
    i:= Pos(delimiter, theString);
    if i > 0 then
    begin
       Result:= Copy(theString, 1, i-1);
       theString:= Copy(theString, i+Length(delimiter), maxLongInt);
    end
    else
    begin
       Result:= theString;
       theString:= '';
    end;
  end;
end;

//function add(a:longint; b:longint):longint;cdecl;
function GetMethodName(methodHeader: string): string;
var
  p: integer;
  aux, firstPart: string;
begin
  p:= Pos('(', methodHeader);
  aux:= Copy(methodHeader, 1, p-1); //function add
  aux:= Trim(aux);
  firstPart:= SplitStr(aux, ' ');
  Result:= Trim(aux);
end;

procedure RunTerminal(fullPathToTerminal: string; initDir: string);
var
  AProcess: TProcess;
begin
  AProcess := TProcess.Create(nil);
  try
    AProcess.InheritHandles := False;
    AProcess.Options := [];
    AProcess.ShowWindow := swoShow;
    AProcess.Executable := fullPathToTerminal;
    if initDir <> '' then
    begin
        AProcess.Parameters.Add('/K');
        AProcess.Parameters.Add('cd /d');
        AProcess.Parameters.Add(initDir);
    end;
    AProcess.Execute;
  finally
    AProcess.Free;
  end;
end;

procedure MakePascalInterface(pathToProject: string; fileName_h: string; libName: string);
var
  fileName_pp: string;
  pathToHFile, pathToH2PAS: string;
  AProcess: TProcess;
  auxList: TStringList;
  flag: boolean;
  i, p1: integer;
  mylib, strAux: string;
  methodName: string;
  auxSignature: string;
  foundResult: string;
  fixedResult: string;
  len: integer;
  index_TYPE_line: integer;
  index_IFDEF_line: integer;
  new_TYPE: string;
begin

  mylib:= libName;

  pathToHFile:= pathToProject;               //C:\TinyC32\LazProjects\LazCProjectSL1
  pathToH2PAS := '$Path($(CompPath))h2pas$(ExeExt)';

  IDEMacros.SubstituteMacros(pathToH2PAS);
  if not FileExists(pathToH2PAS) then
  begin
    ShowMessage(pathToH2PAS + ' not found!');
    Exit;
  end;
  try
    flag:= False;
    AProcess:= TProcess.Create(nil);
    AProcess.CurrentDirectory:= pathToHFile;
    AProcess.Executable:= pathToH2PAS;
    AProcess.Parameters.Add(fileName_h); // .h
    AProcess.Options:= AProcess.Options + [poWaitOnExit];
    AProcess.Execute;      //produce .pp
    flag:= True;
  finally
    AProcess.Free;
    if flag then
    begin
      fileName_pp:=StringReplace(fileName_h, '.h', '.pp', [rfIgnoreCase]);
      auxList:= TStringList.Create;
      auxList.LoadFromFile(pathToProject+ DirectorySeparator + fileName_pp);

      index_TYPE_line:= -1; //dummy
      index_IFDEF_line:= -1; //dummy;

      for i:= 2 to auxList.Count - 1 do  //escape 2 initial lines
      begin

         if Pos('Type', auxList.Strings[i]) > 0 then index_TYPE_line:= i;
         if Pos('{$IFDEF FPC}', auxList.Strings[i]) > 0 then index_IFDEF_line:= i;

         p1:= Pos('):^', auxList.Strings[i]);
         if  p1 > 0 then //try fix Function result ...
         begin
           if Pos('^^', auxList.Strings[i]) = 0 then  //try fix Function result only for one '^'
           begin
             foundResult:= Copy(auxList.Strings[i], p1+2, Length(auxList.Strings[i]));
             len:= 1;
             while foundResult[len] <> ';' do
             begin
               inc(len);
             end;
             foundResult:= Copy(foundResult, 1, len-1);   //ex. ^longint
             fixedResult:=  StringReplace(foundResult, '^' , 'P', [rfIgnoreCase]);  //ex. Plongint
             auxSignature:= auxList.Strings[i];
             auxSignature:= StringReplace(auxSignature, foundResult , fixedResult, [rfIgnoreCase]);
             auxList.Strings[i]:= auxSignature;

             new_TYPE:= fixedResult + ' = ' + foundResult+';';  //try add new type ...
             if Pos(new_TYPE, auxList.Text) = 0 then
             begin
                if (index_TYPE_line > 0) and (index_TYPE_line < auxList.Count) then
                begin
                   auxList.Strings[index_TYPE_line]:= auxList.Strings[index_TYPE_line]+' '+new_TYPE
                end
                else if ((index_IFDEF_line-1) > 0) and ((index_IFDEF_line-1) < auxList.Count) then
                begin
                   auxList.Strings[index_IFDEF_line-1]:= 'Type ' + new_TYPE;
                   index_TYPE_line:= index_IFDEF_line-1;
                end;
             end;

           end;
         end;

         if Pos('{$include ', auxList.Strings[i]) > 0 then
         begin
           strAux:= auxList.Strings[i];
           auxList.Strings[i]:= StringReplace(strAux, '{$include ' , '//include ', [rfIgnoreCase]);
         end;

         if Pos('cdecl;', auxList.Strings[i]) > 0 then
         begin
           methodName:= GetMethodName(auxList.Strings[i]);
           auxList.Strings[i]:= auxList.Strings[i]+ ' external '''+mylib+''' name '''+methodName+''';';
         end;

      end;
      auxList.SaveToFile(pathToProject + DirectorySeparator + fileName_pp);
      auxList.Free;
    end;
  end;
end;

procedure RunCCompile(Sender: TObject);
var
  Tool: TIDEExternalToolOptions;
  strExt, configFile: string;
  Params: TStringList;
  PathToTinyCC, pathToProject: string;
  Project: TLazProject;
  prjfile, cmain: string;
  count, i, countCFile: integer;
  buildMode, libPrefix, paramDynamic: string;
  IsInteractive: string;
begin

  Project:= LazarusIDE.ActiveProject;

  LazarusIDE.DoSaveAll([sfQuietUnitCheck]);

  if Project = nil then Exit;

  if Project.CustomData.Values['LazCWizard'] <> '' then
  begin

      buildMode:=Project.CustomData.Values['LazCWizard'];  //exe, so, dll ...
      libPrefix:= '';
      if buildMode = 'so' then  libPrefix:= 'lib';

      IsInteractive:= Lowercase(Project.CustomData.Values['IsInteractive']); //yes, no

      if buildMode <> 'exe' then IsInteractive:= 'yes';  //launch cmd/terminal...

      Tool := TIDEExternalToolOptions.Create;
      try
        configFile:= LazarusIDE.GetPrimaryConfigPath+ DirectorySeparator+ 'LazCWizard.ini';
        if FileExists(configFile) then
        begin
           with TIniFile.Create(configFile) do
           try
              PathToTinyCC:= ReadString('NewProject','PathToCC', '');
           finally
             Free;
           end;
        end;

        paramDynamic:= '';
        strExt:= '';

        {$IFDEF WINDOWS}
        strExt:= '.exe';
        paramDynamic:= '-rdynamic ';
        {$ENDIF}

        Params:= TStringList.Create;
        Params.Delimiter:=' ';

        IDEMessagesWindow.BringToFront;
        IDEMessagesWindow.Clear;

        Tool.Title := 'Running Extern Tool [TinyCC]... ';

        pathToProject:= ExtractFileDir(Project.ProjectInfoFile);

        Clipboard.AsText:= 'cd '+ pathToProject;
        
        Tool.WorkingDirectory:= pathToProject;
        Tool.Executable := AppendPathDelim(PathToTinyCC) + 'tcc' + strExt;

        cmain:= Project.CustomData.Values['MainC'];

        countCFile:= 0;
        count:= Project.FileCount;
        for i:= 0 to count-1 do
        begin
          if Project.Files[i].IsPartOfProject then
          begin
            prjfile:= ExtractFileName(Project.Files[i].Filename);
            if Pos('.c', prjfile) > 0 then
            begin
              if prjfile <> cmain then
              begin
                 Params.Add(prjfile);
                 Inc(countCFile);
              end;
            end;
          end;

        end;

        Tool.CmdLineParams:= Params.DelimitedText + ' ' + cmain;

        if buildMode = 'exe' then
        begin
           AddIDEMessage(mluVerbose, '[LazCW] building executable...');
           Tool.CmdLineParams:= Tool.CmdLineParams+' -o ' + ChangeFileExt(cmain, strExt);
        end
        else //tcc -shared -rdynamic addc.c -o addc.dll
        begin
           Tool.CmdLineParams:= ' -shared '+ paramDynamic + Tool.CmdLineParams +  ' -o ' + libPrefix+ChangeFileExt(cmain, '.'+ buildMode);
           AddIDEMessage(mluVerbose, '[LazCW] building shared library [.'+buildMode+']...');
        end;


        AddIDEMessage(mluVerbose, '[LazCW] command: "tcc '+Tool.CmdLineParams);

        Tool.Parsers.Add(SubToolDefault);
        RunExternalTool(Tool);

        AddIDEMessage(mluVerbose, '[LazCW] Hint: "paste" path-to-project from clipboard to cmd/terminal...');
        if IsInteractive = 'no' then  //no "must have" cmd/terminal... can output message to Laz IDE
        begin
            AddIDEMessage(mluVerbose, '[LazCW] running program ...');
            Tool.CmdLineParams:= Params.DelimitedText + ' -run ' + cmain;
            AddIDEMessage(mluVerbose, '[LazCW] command: "tcc '+Tool.CmdLineParams+'"');
            RunExternalTool(Tool);
        end
        else
        begin

          if buildMode =  'exe' then
             AddIDEMessage(mluVerbose, '[LazCW] success! executable built!')
          else
             AddIDEMessage(mluVerbose, '[LazCW] success! shared library [.'+buildMode+'] built!');

          {$IFDEF WINDOWS}
          RunTerminal('C:\WINDOWS\System32\cmd.exe', pathToProject);
          {$ENDIF}

          {$IFDEF Linux}    
          RunTerminal('x-terminal-emulator', '');
          {$ENDIF Linux}

        end;

        if buildMode <> 'exe' then
        begin

          {$IFDEF LINUX}
          Param.Clear;
          Param.Add('#!/bin/bash');
          Param.Add('cmd=$*');
          Param.Add('if [ 0 -lt $# ]; then');
          Param.Add('        export LD_LIBRARY_PATH=./');
          Param.Add('        ./$cmd');
          Param.Add('else');
          Param.Add('        echo "missing executable file"');
          Param.Add('fi');
          Param.SaveToFile(AppendPathDelim(pathToProject) + 'run.sh');
          FpChmod(AppendPathDelim(pathToProject) + 'run.sh', &751);
          {$ENDIF}

          MakePascalInterface(pathToProject, ChangeFileExt(cmain, '.h'), libPrefix+ChangeFileExt(cmain, '.'+ buildMode));
        end;

      finally
        Tool.Free;
        Params.Free;
      end;

  end else ShowMessage('Sorry... not a LazCW project...');
end;

procedure Register;
var
  Pkg: TIDEPackage;
  pathToLazCWIcon: string;

  ideMnuLazCWBuild: TIDEMenuCommand;
begin
  pathToLazCWIcon:= '';
  Pkg:=PackageEditingInterface.FindPackageWithName('LazCWizard');
  if Pkg<>nil then
  begin
      pathToLazCWIcon:= ExtractFilePath(Pkg.Filename);
      pathToLazCWIcon:= pathToLazCWIcon + 'LazCW_icon.bmp';
      if not FileExists(pathToLazCWIcon) then pathToLazCWIcon:= '';
  end;
  ideMnuLazCWBuild:=RegisterIDEMenuCommand(itmRunBuilding, 'LazCWBuilder', '[LazCW] Compile/Build  C', nil, @RunCCompile);
  if pathToLazCWIcon <> '' then ideMnuLazCWBuild.Bitmap.LoadFromFile(pathToLazCWIcon);
end;

end.

