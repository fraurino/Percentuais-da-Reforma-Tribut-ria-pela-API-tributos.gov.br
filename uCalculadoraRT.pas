unit uCalculadoraRT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmCalculadoraRT = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCalculadoraRT: TfrmCalculadoraRT;

implementation

uses
  uCalculadoraTributosAPI;

{$R *.dfm}

procedure TfrmCalculadoraRT.FormCreate(Sender: TObject);
var
  API: TCalculadoraTributosAPI;
  Resumo: string;
begin
  API := TCalculadoraTributosAPI.Create;
  try
    Resumo := API.GetResumoTributos(21, 2103000, '2026-01-01');
    memo1.Text := Resumo;
  finally
    API.Free;
  end;
end;


end.
