unit lazc_wizard_form;

{$mode objfpc}{$H+}

interface

uses
  inifiles, Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls;

type

  { TFormLazCWizard }

  TFormLazCWizard = class(TForm)
    bbOK: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBoxInteractive: TCheckBox;
    edPathToImportCode: TEdit;
    edPathWorkspace: TEdit;
    edPathToCC: TEdit;
    edProjectName: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OpenDir: TOpenDialog;
    Panel1: TPanel;
    RadioGroupTarget: TRadioGroup;
    selDir: TSelectDirectoryDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    StatusBar1: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure RadioGroupTargetClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
    { private declarations }
    FPathToWorkspace: string;
    FPathToCC: string;
  public
    { public declarations }
    procedure LoadSettings(const pFilename: string);
    procedure SaveSettings(const pFilename: string);

    property PathToWorkspace: string read FPathToWorkspace write FPathToWorkspace;
    property PathToCC: string read FPathToCC write FPathToCC;

  end;

var
  FormLazCWizard: TFormLazCWizard;

implementation

{$R *.lfm}

{ TFormLazCWizard }

procedure TFormLazCWizard.FormShow(Sender: TObject);
begin

  if edPathToCC.Text = ''  then edPathToCC.SetFocus
  else if edPathWorkspace.Text = '' then edPathWorkspace.SetFocus
  else edProjectName.SetFocus;

end;

procedure TFormLazCWizard.RadioGroupTargetClick(Sender: TObject);
begin
  if RadioGroupTarget.ItemIndex = 1 then
  begin
     CheckBoxInteractive.Checked:= True;
  end;
end;

procedure TFormLazCWizard.SpeedButton1Click(Sender: TObject);
begin
  if SelDir.Execute then
  begin
    edPathWorkspace.Text := SelDir.FileName;
    edProjectName.SetFocus;
  end;
end;

procedure TFormLazCWizard.SpeedButton2Click(Sender: TObject);
begin
  if selDir.Execute then
  begin
    Self.edPathToCC.Text:= selDir.FileName;
    Self.edPathWorkspace.SetFocus;
  end;
end;

procedure TFormLazCWizard.SpeedButton3Click(Sender: TObject);
begin
  ShowMessage('LazCWizard 0.1  [TinyCC Edition]'+sLineBreak +
               sLineBreak + '.Hint: "paste" path-to-project from clipboard to cmd/terminal...' + sLineBreak +
               sLineBreak + '.TinyCC:  http://download.savannah.gnu.org/releases/tinycc/');
end;

procedure TFormLazCWizard.SpeedButton4Click(Sender: TObject);
begin
  if OpenDir.Execute then
  begin
    edPathToImportCode.Text := OpenDir.FileName;
  end;
end;

procedure TFormLazCWizard.LoadSettings(const pFilename: string);
begin
  with TIniFile.Create(pFilename) do
  begin
    FPathToWorkspace:= ReadString('NewProject', 'PathToWorkspace', '');
    FPathToCC:= ReadString('NewProject', 'PathToCC', '');
    Free;
  end;
  edPathWorkspace.Text := FPathToWorkspace;
  edPathToCC.Text := PathToCC;
end;

procedure TFormLazCWizard.SaveSettings(const pFilename: string);
begin
   with TInifile.Create(pFilename) do
   begin
     WriteString('NewProject', 'PathToWorkspace', edPathWorkspace.Text);
     WriteString('NewProject', 'PathToCC', edPathToCC.Text);
     Free;
   end;
end;

end.

