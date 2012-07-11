{**
@Abstract(AFractaler boot)
@Author(Prof1983 prof1983@ya.ru)
@Created(11.07.2012)
@LastMod(11.07.2012)
@Version(0.0)
}
unit AFractalerBoot;

interface

uses
  Forms,
  AFractalerMain,
  Fraccalc,
  UnitFr;

procedure AFractaler_Boot();

implementation

var
  FractalerMainForm: TAFractalerMainForm;

procedure AFractaler_Boot();
begin
  Application.Initialize();
  Application.CreateForm(TAFractalerMainForm, FractalerMainForm);
  Application.Run();
end;

end.
