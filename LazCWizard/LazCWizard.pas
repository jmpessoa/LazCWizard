{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LazCWizard;

{$warn 5023 off : no warning about unused units}
interface

uses
  lazc_wizard_ide_handler, lazc_wizard_ide_menu, lazc_wizard_form, 
  lazc_wizard_intf, lazc_wizard_options_form, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('lazc_wizard_ide_menu', @lazc_wizard_ide_menu.Register);
  RegisterUnit('lazc_wizard_intf', @lazc_wizard_intf.Register);
end;

initialization
  RegisterPackage('LazCWizard', @Register);
end.
