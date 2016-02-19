unit TestTemplateEngine;

interface

uses
  Classes,
  TestFramework,
  TemplateEngine;

type
  TCustomTestTSmartyEngine = class(TTestCase)
  protected
    FEngine: TSmartyEngine;
    procedure CompileExpression(const AExpression: string);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TTestTSmartyEngineSimple = class(TCustomTestTSmartyEngine)
  protected
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSimple;
  end;

  TTestTSmartyEngineModifiers = class(TCustomTestTSmartyEngine)
  protected
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestModifierCat;
    procedure TestModifierCatValue;
    procedure TestModifierTruncate;
    procedure TestModifierTruncateEtc;
    procedure TestModifierTruncateWord;
    procedure TestModifierTruncateMiddle;
  end;

  TTestTSmartyEngineFunctions = class(TCustomTestTSmartyEngine)
  protected
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestModifierTruncate;
    procedure TestModifierTruncateEtc;
    procedure TestModifierTruncateWord;
    procedure TestModifierTruncateMiddle;
    procedure TestModifierTruncateMiddleWordTrue;
  end;

implementation

uses
  SysUtils;

type
  TTestNamespaceStrings = class(TNamespaceProvider)
    class function GetName: string; override;
    class function IsIndexSupported: Boolean; override;
    class function UseCache: Boolean; override;
    procedure GetIndexProperties(var AMin, AMax: Integer); override;
    function GetVariable(AIndex: Integer;
      AVarName: string): TVariableRecord; override;
  end;

{ TTestNamespaceSimple }

procedure TTestNamespaceStrings.GetIndexProperties(var AMin, AMax: integer);
begin
  AMin := 0;
  AMax := 0;
end;

class function TTestNamespaceStrings.GetName: string;
begin
  Result := 'strings';
end;

function TTestNamespaceStrings.GetVariable(AIndex: integer;
  AVarName: string): TVariableRecord;
begin
  if SameText(AVarName, 'key') then
    Result := 'var!key'
  else if SameText(AVarName, 'value') then
    Result := 'var!value'
  else
    Result := TVariableRecord.Null;
end;

class function TTestNamespaceStrings.IsIndexSupported: boolean;
begin
  Result := False;
end;

class function TTestNamespaceStrings.UseCache: boolean;
begin
  Result := True;
end;

{ TCustomTestTSmartyEngine }

procedure TCustomTestTSmartyEngine.CompileExpression(const AExpression: string);
var
  LErrors: TStringList;
begin
  LErrors := TStringList.Create;
  try
    if not FEngine.Compile(AExpression, LErrors) then
      Fail(Format('Expression compilation failure: %s; %s',
        [AExpression, LErrors.Text]));
  finally
    FreeAndNil(LErrors);
  end;
end;

procedure TCustomTestTSmartyEngine.SetUp;
begin
  inherited;
  FEngine := TSmartyEngine.Create;
  FEngine.AddNamespace(TTestNamespaceStrings.Create);
end;

procedure TCustomTestTSmartyEngine.TearDown;
begin
  FreeAndNil(FEngine);
  inherited;
end;

{ TTestTSmartyEngineModifiers }

procedure TTestTSmartyEngineModifiers.SetUp;
begin
  inherited;

end;

procedure TTestTSmartyEngineModifiers.TearDown;
begin
  inherited;

end;

procedure TTestTSmartyEngineModifiers.TestModifierCat;
begin
  CompileExpression('modifier: {$strings.key | cat}');
  CheckEquals('modifier: var!key', FEngine.Execute);
end;

procedure TTestTSmartyEngineModifiers.TestModifierCatValue;
begin
  CompileExpression('modifier: {$strings.key | cat:value}');
  CheckEquals('modifier: var!keyvalue', FEngine.Execute);
end;

procedure TTestTSmartyEngineModifiers.TestModifierTruncate;
begin
  CompileExpression('truncate: {$strings.key|truncate:4}');
  CheckEquals('truncate: var...', FEngine.Execute);

  CompileExpression('truncate: {$strings.key|truncate:4:}');
  CheckEquals('truncate: var...', FEngine.Execute, '2');
end;

procedure TTestTSmartyEngineModifiers.TestModifierTruncateEtc;
begin
  CompileExpression('truncate: {$strings.key|truncate:4: :}');
  CheckEquals('truncate: var ', FEngine.Execute);

  CompileExpression('truncate: {$strings.key|truncate:4:-}');
  CheckEquals('truncate: var-', FEngine.Execute);
end;

procedure TTestTSmartyEngineModifiers.TestModifierTruncateMiddle;
begin
  CompileExpression('truncate: {$strings.key|truncate:4:::TRUE}');
  CheckEquals('truncate: vaey', FEngine.Execute);

  CompileExpression('truncate: {$strings.key|truncate:4: ::TRUE}');
  CheckEquals('truncate: va ey', FEngine.Execute);

  CompileExpression('truncate: {$strings.key|truncate:4:-::TRUE}');
  CheckEquals('truncate: va-ey', FEngine.Execute);
end;

procedure TTestTSmartyEngineModifiers.TestModifierTruncateWord;
begin
  CompileExpression('truncate: {$strings.key|truncate:4::TRUE}');
  CheckEquals('truncate: var!', FEngine.Execute);

  CompileExpression('truncate: {$strings.key|truncate:3::}');
  CheckEquals('truncate: var', FEngine.Execute);

  CompileExpression('truncate: {$strings.key|truncate:4:-:TRUE}');
  CheckEquals('truncate: var!-', FEngine.Execute);
end;

{ TTestTSmartyEngineSimple }

procedure TTestTSmartyEngineSimple.SetUp;
begin
  inherited;

end;

procedure TTestTSmartyEngineSimple.TearDown;
begin
  inherited;

end;

procedure TTestTSmartyEngineSimple.TestSimple;
begin
  CompileExpression('string: {$strings.key} -> {$strings.value}');
  CheckEquals('string: var!key -> var!value', FEngine.Execute);
end;

{ TTestTSmartyEngineFunctions }

procedure TTestTSmartyEngineFunctions.SetUp;
begin
  inherited;

end;

procedure TTestTSmartyEngineFunctions.TearDown;
begin
  inherited;

end;

procedure TTestTSmartyEngineFunctions.TestModifierTruncate;
begin
  CompileExpression('truncate: {truncate($strings.key, 4)}');
  CheckEquals('truncate: var...', FEngine.Execute);
end;

procedure TTestTSmartyEngineFunctions.TestModifierTruncateEtc;
begin
  CompileExpression('truncate: {truncate($strings.key, 4, " ")}');
  CheckEquals('truncate: var ', FEngine.Execute);

  CompileExpression('truncate: {truncate($strings.key, 4, "-")}');
  CheckEquals('truncate: var-', FEngine.Execute);
end;

procedure TTestTSmartyEngineFunctions.TestModifierTruncateMiddle;
begin
  CompileExpression('truncate: {truncate($strings.key, 4, "", FALSE, TRUE)}');
  CheckEquals('truncate: vaey', FEngine.Execute);

  CompileExpression('truncate: {truncate($strings.key, 4, " ", FALSE, TRUE)}');
  CheckEquals('truncate: va ey', FEngine.Execute);

  CompileExpression('truncate: {truncate($strings.key, 4, "-", FALSE, TRUE)}');
  CheckEquals('truncate: va-ey', FEngine.Execute);
end;

procedure TTestTSmartyEngineFunctions.TestModifierTruncateMiddleWordTrue;
begin
  CompileExpression('truncate: {truncate($strings.key, 4, "", TRUE, TRUE)}');
  CheckEquals('truncate: vaey', FEngine.Execute);

  CompileExpression('truncate: {truncate($strings.key, 4, " ", TRUE, TRUE)}');
  CheckEquals('truncate: va ey', FEngine.Execute);

  CompileExpression('truncate: {truncate($strings.key, 4, "-", TRUE, TRUE)}');
  CheckEquals('truncate: va-ey', FEngine.Execute);
end;

procedure TTestTSmartyEngineFunctions.TestModifierTruncateWord;
begin
  CompileExpression('truncate: {truncate($strings.key, 4, "", TRUE)}');
  CheckEquals('truncate: var!', FEngine.Execute);

  CompileExpression('truncate: {truncate($strings.key, 4, "-", TRUE)}');
  CheckEquals('truncate: var!-', FEngine.Execute);
end;

initialization
  RegisterTest(TTestTSmartyEngineSimple.Suite);
  RegisterTest(TTestTSmartyEngineModifiers.Suite);
  RegisterTest(TTestTSmartyEngineFunctions.Suite);
end.