unit uCalculadoraRT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
   System.Generics.Collections,  System.JSON,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.ComCtrls, Vcl.Mask,
  uCalculadoraTributosAPI, UClassificacaoTributaria;

type
  TfrmCalculadoraRT = class(TForm)
    PageControl1: TPageControl;
    tsAliquotas: TTabSheet;
    TabSheet2: TTabSheet;
    StringGrid1: TStringGrid;
    mAliquotas: TMemo;
    cClassTrib: TLabeledEdit;
    SpeedButton4: TSpeedButton;
    CSTtocClassTrib: TLabeledEdit;
    lista: TMemo;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton7Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    Gerenciador: TGerenciadorClassificacaoTributaria;
    ClassificacaoTrib: TClassificacaoTributaria;
  end;

var
  frmCalculadoraRT: TfrmCalculadoraRT;


implementation


{$R *.dfm}




procedure TfrmCalculadoraRT.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Gerenciador.Free;
end;

procedure TfrmCalculadoraRT.SpeedButton1Click(Sender: TObject);
var
  API: TCalculadoraTributosAPI;
  Resumo: string;
begin
  API := TCalculadoraTributosAPI.Create;
  try
    Resumo := API.GetResumoTributos(21, 2103000, '2026-01-01');
    mAliquotas.Text := Resumo;
  finally
    API.Free;
  end;
end;

procedure TfrmCalculadoraRT.SpeedButton2Click(Sender: TObject);
var
  CST: string;
  ListaCST: TList<string>;
  i: Integer;
  OpenDialog : TOpenDialog;
  arquivojson : string ;
begin

  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Title       := 'Selecionar Arquivo de Classificação Tributária';
    OpenDialog.Filter      := 'Arquivos JSON|*.json|Todos os arquivos|*.*';
    OpenDialog.FilterIndex := 1;
    OpenDialog.DefaultExt  := 'json';
    OpenDialog.InitialDir  := GetEnvironmentVariable('USERPROFILE') + '\Downloads';
    OpenDialog.Options     := [ofFileMustExist, ofHideReadOnly, ofPathMustExist];

    if OpenDialog.Execute then
      arquivojson := OpenDialog.FileName;
  finally
    OpenDialog.Free;
  end;


  Gerenciador := TGerenciadorClassificacaoTributaria.Create(arquivojson);
  try
    Gerenciador.Carregar;
    PreencherStringGridCompleto(StringGrid1, Gerenciador);
  finally
    Gerenciador.Free;
  end;

   exit;

  // Criar gerenciador apontando para o arquivo JSON
  Gerenciador := TGerenciadorClassificacaoTributaria.Create(arquivojson);

  try
    // Carregar dados
    Gerenciador.Carregar;
    TabSheet2.Caption := 'Arquivo JSON | Total de registros: ' + IntToStr(Gerenciador.ObterTotal) ;

    // BUSCAR CST PELA CLASSIFICAÇÃO
    CST := Gerenciador.BuscarCSTporClasificacao('000001');
    ShowMessage('CST para 000001: ' + CST); // Resultado: 000

    // BUSCAR CLASSIFICAÇÕES PELO CST
    ListaCST := Gerenciador.BuscarClassificacaoPorCST('200');
    try
      for i := 0 to ListaCST.Count - 1 do
        ShowMessage('Classificação: ' + ListaCST[i]);
    finally
      ListaCST.Free;
    end;

    // OBTER REGISTRO COMPLETO
    ClassificacaoTrib := Gerenciador.BuscarRegistroPorClasificacao('200001');
    ShowMessage(Gerenciador.ObterDescricaoFormatada(ClassificacaoTrib));

  finally
    Gerenciador.Free;
  end;
end;


procedure TfrmCalculadoraRT.SpeedButton4Click(Sender: TObject);
var
  CST: string;
  ListaCST: TList<string>;
  i: Integer;
begin
    // BUSCAR CST PELA CLASSIFICAÇÃO
    CSTtocClassTrib.Clear;
    CST := Gerenciador.BuscarCSTporClasificacao(cClassTrib.text);
    CSTtocClassTrib.text := CST ;
end;

procedure TfrmCalculadoraRT.SpeedButton5Click(Sender: TObject);
var
  CST: string;
  ListaCST: TList<string>;
  i: Integer;
begin
    // BUSCAR CLASSIFICAÇÕES PELO CST
    ListaCST := Gerenciador.BuscarClassificacaoPorCST(CSTtocClassTrib.Text);
    try
      lista.Clear;
      for i := 0 to ListaCST.Count - 1 do
        begin
          lista.Lines.Add('CST '+ CSTtocClassTrib.text + ' para ClassTrib: ' + ListaCST[i]) ;
        end;
    finally
      ListaCST.Free;
    end;
end;
procedure TfrmCalculadoraRT.SpeedButton6Click(Sender: TObject);
var
  CST: string;
  ListaCST: TList<string>;
  i: Integer;
  OpenDialog : TOpenDialog;
  arquivojson : string ;
begin

  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Title       := 'Selecionar Arquivo de Classificação Tributária';
    OpenDialog.Filter      := 'Arquivos JSON|*.json|Todos os arquivos|*.*';
    OpenDialog.FilterIndex := 1;
    OpenDialog.DefaultExt  := 'json';
    OpenDialog.InitialDir  := GetEnvironmentVariable('USERPROFILE') + '\Downloads';
    OpenDialog.Options     := [ofFileMustExist, ofHideReadOnly, ofPathMustExist];

    if OpenDialog.Execute then
      arquivojson := OpenDialog.FileName;
  finally
    OpenDialog.Free;
  end;


  // Criar gerenciador apontando para o arquivo JSON
  Gerenciador := TGerenciadorClassificacaoTributaria.Create(arquivojson);
  Gerenciador.Carregar;

end;

procedure TfrmCalculadoraRT.SpeedButton7Click(Sender: TObject);
begin
  PreencherStringGridCompleto(StringGrid1, Gerenciador);
end;

end.
