unit lazc_wizard_intf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LazFileUtils, Controls, Forms, Dialogs,
  LazIDEIntf, ProjectIntf, FormEditingIntf, lazc_wizard_form;

type


  { TLazCWProjectDescriptor }

  TLazCWProjectDescriptor = class(TProjectDescriptor)
  private
    FNewProjectName: string;
    FPathToProject: string;
    FPathToWorkspace: string;
    FPathToCC: string;
    FPathToImportCode: string;
    FInteractiveConsole: boolean;   //True - if program need console interaction...
    FBuildMode: string;
    function SettingsFilename: string;
    function NewProjectOK: boolean;


  public
    constructor Create; override;
    destructor Destroy; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function DoInitDescriptor: TModalResult; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
    property BuildMode: string read FBuildMode;
    property PathToImportCode: string read FPathToImportCode;

  end;


  TLazCWCFileDescritor = class (TProjectFileDescriptor)
  public
    constructor Create; override;
    function CreateSource(const Filename     : string;
                          const SourceName   : string;
                          const ResourceName : string): string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;

  end;

  TLazCWHeaderFileDescritor = class(TProjectFileDescriptor)
  public
    constructor Create; override;
    function CreateSource(const Filename     : string;
                          const SourceName   : string;
                          const ResourceName : string): string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;

  end;


var
  LazCWProjectDescriptor: TLazCWProjectDescriptor;
  LazCWCFileDescritor: TLazCWCFileDescritor;
  LazCWHeaderFileDescritor: TLazCWHeaderFileDescritor;

procedure Register;


implementation

uses
  lazc_wizard_ide_handler;

procedure Register;
begin
  LazCWProjectDescriptor := TLazCWProjectDescriptor.Create;
  RegisterProjectDescriptor(LazCWProjectDescriptor);

  LazCWCFileDescritor := TLazCWCFileDescritor.Create;
  RegisterProjectFileDescriptor(LazCWCFileDescritor);

  LazCWHeaderFileDescritor:= TLazCWHeaderFileDescritor.Create;
  RegisterProjectFileDescriptor(LazCWHeaderFileDescritor);

   LazCWHandleIDE.Init;
end;


 {TLazCWProjectDescriptor}


function TLazCWProjectDescriptor.SettingsFilename: string;
begin
  Result := AppendPathDelim(LazarusIDE.GetPrimaryConfigPath) +  'LazCWizard.ini'
end;

function TLazCWProjectDescriptor.NewProjectOK: boolean;


  function MakeUniqueName(const Orig: string; sl: TStrings): string;
  var
    i: Integer;
  begin
    if sl.Count = 0 then
      Result := Orig + '1'
    else begin
      Result := ExtractFilePath(sl[0]) + Orig;
      i := 1;
      while sl.IndexOf(Result + IntToStr(i)) >= 0 do Inc(i);
      Result := Orig + IntToStr(i);
    end;
  end;


var
   frm: TFormLazCWizard;
   listProj: TStringList;
begin

  Result := False;

  frm := TFormLazCWizard.Create(nil);
  frm.LoadSettings(SettingsFilename);

  if frm.edPathWorkspace.Text <> '' then
  begin
     listProj:= TStringList.Create;
     FindAllDirectories(listProj, frm.edPathWorkspace.Text , False);
     frm.edProjectName.Text:= MakeUniqueName('LazCProject', listProj);
     listProj.Free;
  end;

  if frm.ShowModal = mrOK then
  begin
    if frm.edPathToCC.Text = '' then Exit;
    if frm.edPathWorkspace.Text = '' then Exit;
    if frm.edProjectName.Text = '' then Exit;

    if not DirectoryExists(frm.edPathWorkspace.Text) then
    begin
      ShowMessage('Sorry... Path to Projects/Workspace does not exist'+sLineBreak+'[' + frm.edPathWorkspace.Text + '].')
    end
    else
    begin
      if DirectoryExists(AppendPathDelim(frm.edPathWorkspace.Text) + frm.edProjectName.Text) then
      begin
          ShowMessage('Sorry... Project directory already exists!')
      end
      else
      begin
          FPathToProject:= AppendPathDelim(Trim(frm.edPathWorkspace.Text)) + Trim(frm.edProjectName.Text);
          if not CreateDir(FPathToProject) then
          begin
            ShowMessage('Sorry.. Fail creating project directory...')
          end
          else
          begin
             Result := true;
             FPathToWorkspace:= Trim(frm.edPathWorkspace.Text);
             FNewProjectName:= StringReplace(trim(frm.edProjectName.Text), ' ', '', [rfReplaceAll]);
             FPathToCC:= trim(frm.edPathToCC.Text);
             FInteractiveConsole:= frm.CheckBoxInteractive.Checked;

             FPathToImportCode:= trim(frm.edPathToImportCode.Text);

             FBuildMode:= 'exe';  //default
             if frm.RadioGroupTarget.ItemIndex = 1 then  //change...
             begin

               {$IFDEF Linux}
                 FBuildMode:= 'so';
               {$ENDIF Linux}

               {$IFDEF Windows}
                 FBuildMode:= 'dll';
               {$ENDIF Windows}

             end;

             frm.SaveSettings(SettingsFilename);
          end;
      end;
    end;
  end;

  frm.Free;

end;

constructor TLazCWProjectDescriptor.Create;
begin
  inherited Create;
  Name := 'LazCW Project';
end;

destructor TLazCWProjectDescriptor.Destroy;
begin
  inherited Destroy;
end;

function TLazCWProjectDescriptor.GetLocalizedName: string;
begin
  Result := 'LazCW Project';
end;

function TLazCWProjectDescriptor.GetLocalizedDescription: string;
begin
  Result:= '[LazCW] Create a new NoGUI/Console C Project...';
end;

function TLazCWProjectDescriptor.DoInitDescriptor: TModalResult;
begin
  if NewProjectOK then
    begin
      result := mrOK;
    end
  else
    Result := mrAbort
end;

function TLazCWProjectDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  NewSource: TStringList;
  MainFile: TLazProjectFile;
begin
  inherited InitProject(AProject);

  NewSource:= TStringList.Create;

  //dummy
  NewSource.Add('program '+FNewProjectName+'; //[do not touch!]. Close this editor Tab!');
  NewSource.Add('begin');
  NewSource.Add('  writeln(''LazCWizard empty/bootstrap Project... '');');
  NewSource.Add('end.');
  MainFile := AProject.CreateProjectFile( FPathToProject + DirectorySeparator+ Lowercase(FNewProjectName) + '.lpr');
  MainFile.SetSourceText(NewSource.Text);
  MainFile.IsPartOfProject := True;
  AProject.AddFile(MainFile, False {not Added to project Uses clause});
  AProject.MainFileID := 0;
  AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements,
                                      pfMainUnitHasTitleStatement,
                                      pfMainUnitHasScaledStatement];
  AProject.UseManifest:= False;
  AProject.UseAppBundle:= False;
  //end dummy

  AProject.AddPackageDependency('LazC');

  AProject.CustomData.Values['LazCWizard']:= FBuildMode; //exe or so ....
  AProject.CustomData.Values['Version']:= '0.1';
  AProject.CustomData.Values['MainC']:= Lowercase(FNewProjectName) + '.c';

  if FInteractiveConsole then
    AProject.CustomData.Values['IsInteractive']:= 'yes'
  else
    AProject.CustomData.Values['IsInteractive']:= 'no';

  //dummy ....
  AProject.LazCompilerOptions.IncludePath:='$(ProjOutDir)';                            //-Fi
  AProject.LazCompilerOptions.UnitOutputDirectory := '\lib\$(TargetCPU)-$(TargetOS)';  //-FU
  AProject.LazCompilerOptions.TargetFilename:= FNewProjectName;                         //-o
  AProject.LazCompilerOptions.Win32GraphicApp:= False;
  AProject.LazCompilerOptions.GenerateDebugInfo:= False;
  //end dummy

  AProject.ProjectInfoFile := FPathToProject + DirectorySeparator + ChangeFileExt(FNewProjectName, '.lpi');

  NewSource.Free;
  Result := mrOK;
end;

function TLazCWProjectDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult;
begin
  if AProject = nil then Exit;

  LazarusIDE.DoNewEditorFile(LazCWCFileDescritor,
                             AppendPathDelim(FPathToProject) + Lowercase(FNewProjectName)+'.c','',
                             [nfIsPartOfProject,nfOpenInEditor, nfCreateDefaultSrc]);

  if FBuildMode <> 'exe' then  //library
     LazarusIDE.DoNewEditorFile(LazCWHeaderFileDescritor,
                             AppendPathDelim(FPathToProject) + Lowercase(FNewProjectName)+'.h','',
                             [nfIsPartOfProject,nfOpenInEditor, nfCreateDefaultSrc]);

  LazarusIDE.DoSaveProject([]);

  Result := mrOK;
end;


{TLazCWCFileDescritor}

constructor TLazCWCFileDescritor.Create;
begin
 inherited Create;
 DefaultFilename:= 'unitc1';
 DefaultFileExt:= '.c';
 UseCreateFormStatements:= False;
 IsPascalUnit:= False;
 Name := 'CFileDescritor';
end;

function TLazCWCFileDescritor.CreateSource(const Filename: string;
                                                      const SourceName: string;
                                                      const ResourceName: string): string;
var
  NewSource: TStringList;
  main: string;
begin
  NewSource:= TStringList.Create;
  if (Pos(':', Filename) > 0) or (Filename[1]='/') then
  begin
    main:= ExtractFileName(Filename);
    NewSource.Add('/*'+main+'*/');
    NewSource.Add(' ');
    NewSource.Add('#include <stdio.h>');
    NewSource.Add('#include <stdlib.h>');
    NewSource.Add('#include <math.h>');
    NewSource.Add('#include <string.h>');
    NewSource.Add('');
    if LazCWProjectDescriptor.BuildMode = 'exe' then
    begin
      if LazCWProjectDescriptor.PathToImportCode = '' then
      begin
        NewSource.Add('main()');
        NewSource.Add('{');
        NewSource.Add('  printf("\n Hello C World! \n");');
        NewSource.Add('  return 0;');
        NewSource.Add('}');
      end
      else NewSource.LoadFromFile(LazCWProjectDescriptor.PathToImportCode);
    end
    else //shared library
    begin
      NewSource.Add('int addTwo(int a, int b) {');
      NewSource.Add('   return (a+b);');
      NewSource.Add('}');
    end;
  end
  else
  begin
    NewSource.Add('/*.c*/');
    NewSource.Add(' ');
    NewSource.Add('#include <stdio.h>');
    NewSource.Add('#include <stdlib.h>');
    NewSource.Add('#include <math.h>');
    NewSource.Add('#include <string.h>');
  end;
  Result:= NewSource.Text;
  NewSource.Free;
end;


function TLazCWCFileDescritor.GetLocalizedName: string;
begin
   Result:= '[LazCW] Create a new .c file';
end;

function TLazCWCFileDescritor.GetLocalizedDescription: string;
begin
   Result:= '[LazCW] Create a new .c project file';
end;

{TTLazCWHeaderFileDescritor}

constructor TLazCWHeaderFileDescritor.Create;
begin
 inherited Create;
 DefaultFilename:= 'unitc1';
 DefaultFileExt:= '.h';
 UseCreateFormStatements:= False;
 IsPascalUnit:= False;

 Name:= 'CHeaderFileDescritor';
end;

function TLazCWHeaderFileDescritor.CreateSource(const Filename     : string;
                                                      const SourceName   : string;
                                                      const ResourceName : string): string;
begin

  Result:= '/*.h*/'+sLineBreak;

  {Here "extern" help the FreePascal tool "h2pas" convert the header from c to pascal... }
  if (Pos(':', Filename) > 0) or (Filename[1]='/') then //shared library
     Result:= Result + sLineBreak + sLineBreak + 'extern int addTwo(int a, int b);'; // extern/exported...


end;

function TLazCWHeaderFileDescritor.GetLocalizedName: string;
begin
   Result:= '[LazCW] Create a new .h file'; //menu
end;

function TLazCWHeaderFileDescritor.GetLocalizedDescription: string;
begin
   Result:= '[LazCW] Create a new .h project file'; //description detail
end;


end.


