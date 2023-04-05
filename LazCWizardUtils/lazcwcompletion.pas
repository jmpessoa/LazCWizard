{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LazCWCompletion;

{$warn 5023 off : no warning about unused units}
interface

uses
  LazCWUtil, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('LazCWUtil', @LazCWUtil.Register);
end;

initialization
  RegisterPackage('LazCWCompletion', @Register);
end.
