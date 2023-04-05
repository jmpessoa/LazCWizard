unit lazc_wizard_options_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  IDEOptionsIntf, ProjectIntf, LCLVersion, LResources, StdCtrls,
  LazIDEIntf, IDEOptEditorIntf;

type

  { TFormLazCWOptions }

  TFormLazCWOptions = class(TAbstractIDEOptionsEditor)
    cbIsInteractive: TComboBox;
    cbMainC: TComboBox;
    cbBuildMode: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PageControlLazCW: TPageControl;
    TabSheet1: TTabSheet;
  private
    FIsLazCWProject: boolean;
    FIsInteractive: string; //true, false
    FBuildMode: string; //exe,  dll, so
    FMainC: string; //lazcproject7
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function SupportedOptionsClass: TAbstractIDEOptionsClass; override;
    function GetTitle: String; override;
    procedure Setup({%H-}ADialog: TAbstractOptionsEditorDialog); override;
    procedure ReadSettings({%H-}AOptions: TAbstractIDEOptions); override;
    procedure WriteSettings({%H-}AOptions: TAbstractIDEOptions); override;
  end;

var
  FormLazCWOptions: TFormLazCWOptions;

implementation

{$if (lcl_fullversion >= 1090000)}
  //uses
    //IDEOptEditorIntf;
{$endif}



{$R *.lfm}

{ TFormLazCWOptions }

constructor TFormLazCWOptions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TFormLazCWOptions.Destroy;
begin
  inherited Destroy;
end;

class function TFormLazCWOptions.SupportedOptionsClass: TAbstractIDEOptionsClass;
begin
  Result := nil;
end;

function TFormLazCWOptions.GetTitle: String;
begin
   Result := '[LazCW] C Project Options';
end;

procedure TFormLazCWOptions.Setup(ADialog: TAbstractOptionsEditorDialog);
begin
  // localization
end;

procedure TFormLazCWOptions.ReadSettings(AOptions: TAbstractIDEOptions);
var
  proj: TLazProject;
  i, count, mainIndex: integer;
  auxStr: string;
begin
 proj := LazarusIDE.ActiveProject;
 if (proj = nil) or (proj.IsVirtual) then Exit;

 if not proj.CustomData.Contains('LazCWizard') then
 begin
   FIsLazCWProject:= False;
   Exit;
 end;
 FIsLazCWProject:= True;

 FIsInteractive:= proj.CustomData['IsInteractive'];

 cbIsInteractive.Text:= 'yes';
 cbIsInteractive.ItemIndex:= 0;
 if FIsInteractive = 'no' then
 begin
   cbIsInteractive.Text:= 'no';
   cbIsInteractive.ItemIndex:= 1;
 end;

 {$IFDEF Windows}
   cbBuildMode.Items.Add('dll');
 {$ENDIF Windows}

 {$IFDEF linux}
   cbBuildMode.Items.Add('so');
 {$ENDIF linux}

 FBuildMode:= proj.CustomData['LazCWizard'];

 cbBuildMode.Text:= 'exe';
 cbBuildMode.ItemIndex:= 0;

 if FBuildMode <> 'exe' then
 begin
   cbBuildMode.ItemIndex:= 1;
   cbBuildMode.Text:= cbBuildMode.Items.Strings[1];
 end;

 FMainC:= proj.CustomData['MainC'];

 count:= proj.FileCount;

 mainIndex:= -1;

 for i:= 0 to count-1 do
 begin
   if proj.Files[i].IsPartOfProject then
   begin
     auxStr:= ExtractFileName(proj.Files[i].Filename);
     if Pos('.c', auxStr) >  0then
     begin
        cbMainC.Items.Add(auxStr);
        if auxStr = FMainC then mainIndex:= cbMainC.Items.Count - 1;
     end;
   end;
 end;

 cbMainC.Text:= FMainC;
 if mainIndex <> -1 then cbMainC.ItemIndex:= mainIndex;

end;

procedure TFormLazCWOptions.WriteSettings(AOptions: TAbstractIDEOptions);
begin
  if not FIsLazCWProject then Exit;


  //yes, no
  if cbIsInteractive.Text <> '' then
    LazarusIDE.ActiveProject.CustomData['IsInteractive']:= cbIsInteractive.Text;


  //exe so dll
  if cbBuildMode.Text <> '' then
    LazarusIDE.ActiveProject.CustomData['LazCWizard']:= cbBuildMode.Text;

  if cbMainC.Text <> '' then
    LazarusIDE.ActiveProject.CustomData['MainC']:= cbMainC.Text;

end;

initialization
  RegisterIDEOptionsEditor(GroupProject, TFormLazCWOptions, 1001);


end.

