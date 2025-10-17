program CalculadoraRT;

uses
  Vcl.Forms,
  uCalculadoraRT in 'uCalculadoraRT.pas' {frmCalculadoraRT},
  uCalculadoraTributosAPI in 'uCalculadoraTributosAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmCalculadoraRT, frmCalculadoraRT);
  Application.Run;
end.
