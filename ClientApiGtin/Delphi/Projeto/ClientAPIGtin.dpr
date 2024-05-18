program ClientAPIGtin;

uses
  Vcl.Forms,
  uFrmMainClientGtin in '..\View\uFrmMainClientGtin.pas' {FrmGtin},
  Controller.Gtin in '..\Controller\Controller.Gtin.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown :=  True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmGtin, FrmGtin);
  Application.Run;
end.
