unit TemplateEngineCustomFunctions;

interface

uses
  Classes,
  TemplateEngine;

type
  TAdjustToRightFunction = class(TSmartyFunction)
  public
    class function GetName: string; override;
    class function CheckParams(AParamsCount: integer): boolean; override;
    class function Evaluate(AParams: array of TVariableRecord): TVariableRecord; override;
  end;

implementation

uses
  SysUtils, StrUtils;

{ TAdjustToRightFunction }

class function TAdjustToRightFunction.CheckParams(AParamsCount: integer): boolean;
begin
	Result := AParamsCount = 2;
end;

class function TAdjustToRightFunction.Evaluate(
  AParams: array of TVariableRecord): TVariableRecord;
var
  LSize: Integer;
begin
  LSize := GetParam(0, AParams).ToInt;
  Result := StrUtils.RightStr(
    DupeString(' ', LSize) + GetParam(1, AParams).ToString,
    LSize);
end;

class function TAdjustToRightFunction.GetName: string;
begin
  Result := 'right';
end;

initialization
  TemplateEngine.RegisterFunction(TAdjustToRightFunction);

end.
