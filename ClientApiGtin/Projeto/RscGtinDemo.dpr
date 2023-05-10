program RscGtinDemo;

uses
  Vcl.Forms,
  uFrmGtin in '..\View\uFrmGtin.pas' {FrmGtin},
  uRscGtin.Classes in '..\Classes\uRscGtin.Classes.pas',
  uRscGtin.Consts in '..\Consts\uRscGtin.Consts.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown :=  True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmGtin, FrmGtin);
  Application.Run;
end.
