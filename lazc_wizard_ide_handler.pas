unit lazc_wizard_ide_handler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazIDEIntf, ProjectIntf, Controls, Forms, Dialogs;

type

  { TLazCWHandleIDE }

  TLazCWHandleIDE = class
  public
    Destructor Destroy; override;
    procedure Init;
    function OnProjectOpened(Sender: TObject; AProject: TLazProject): TModalResult;
  end;

var
  LazCWHandleIDE: TLazCWHandleIDE;

implementation

{ TLazCWHandleIDE }

destructor TLazCWHandleIDE.Destroy;
begin
  if LazarusIDE <> nil then
    LazarusIDE.RemoveAllHandlersOfObject(Self);

  inherited Destroy;
end;

procedure TLazCWHandleIDE.Init;
begin
   LazarusIDE.AddHandlerOnProjectOpened(@OnProjectOpened);
end;

function TLazCWHandleIDE.OnProjectOpened(Sender: TObject; AProject: TLazProject): TModalResult;
begin
  if AProject.CustomData.Contains('LazCWizard') then
  begin
    LazarusIDE.DoCloseEditorFile(AProject.Files[0].Filename, [cfQuiet]);
  end;
  Result := mrOK;
end;

initialization
   LazCWHandleIDE:= TLazCWHandleIDE.Create;

finalization
   LazCWHandleIDE.Free;

end.

