unit UClassificacaoTributaria;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Vcl.ExtCtrls,
  Dialogs,
  Forms,
  System.IOUtils,
  System.StrUtils,
  Vcl.Grids,
  System.JSON;

type
  // Type para armazenar dados de uma classificação tributária
  TClassificacaoTributaria = record
    CodigoSituacaoTributaria: string;
    DescricaoSituacaoTributaria: string;
    TributacaoRegular: Boolean;
    ReducaoBCCST: Boolean;
    ReducaoAliquota: Boolean;
    TransferenciaCredito: Boolean;
    Diferimento: Boolean;
    Monofasica: Boolean;
    CreditoPresumidoIBSZFM: Boolean;
    AjusteCompetencia: Boolean;
    CodigoClassificacaoTributaria: string;
    DescricaoClassificacao: string;
    PercentualReducaoIBS: Integer;
    PercentualReducaoCBS: Integer;
    ReducaoBC: Boolean;
    CreditoPresumido: Boolean;
    EstornoCredito: Boolean;
    TipoAliquota: string;
    NFe: Boolean;
    NFCe: Boolean;
    CTe: Boolean;
    CTeOS: Boolean;
    BPe: Boolean;
    NF3e: Boolean;
    NFCom: Boolean;
    NFSE: Boolean;
    BPeTM: Boolean;
    BPeTA: Boolean;
    NFAg: Boolean;
    NFSVIA: Boolean;
    NFABI: Boolean;
    NFGas: Boolean;
    DERE: Boolean;
    NumeroAnexo: string;
    UrlLegislacao: string;
  end;

  // Lista de classificações tributárias
  TListaClassificacoes = TList<TClassificacaoTributaria>;

  // Classe principal para gerenciar classificações tributárias
  TGerenciadorClassificacaoTributaria = class
  private
    FListaClassificacoes: TListaClassificacoes;
    FArquivoJSON: string;
    procedure CarregarDoJSON;
    function StringParaBoolean(const AValor: string): Boolean;
    function StringParaInteger(const AValor: string): Integer;
  public
    constructor Create(const AArquivoJSON: string);
    destructor Destroy; override;

    // Carrega os dados do arquivo JSON
    procedure Carregar;

    // Retorna a quantidade de registros
    function ObterTotal: Integer;

    // Busca CST pela Classificação (ClasTrib)
    function BuscarCSTporClasificacao(const ACodigoClassificacao: string): string;

    // Busca Classificação pelo CST
    function BuscarClassificacaoPorCST(const ACodigoCST: string): TList<string>;

    // Busca um registro completo pela Classificação
    function BuscarRegistroPorClasificacao(const ACodigoClassificacao: string): TClassificacaoTributaria;

    // Busca registros completos pelo CST
    function BuscarRegistrosPorCST(const ACodigoCST: string): TListaClassificacoes;

    // Retorna a lista completa de classificações
    function ObterTodos: TListaClassificacoes;

    // Retorna uma descrição formatada de um registro
    function ObterDescricaoFormatada(const AClassificacao: TClassificacaoTributaria): string;
  end;

/// <summary>
/// Preenche StringGrid com todos os dados das classificações tributárias
/// </summary>
procedure PreencherStringGridCompleto(const AStringGrid: TStringGrid;
                                      const AGerenciador: TGerenciadorClassificacaoTributaria);

/// <summary>
/// Preenche StringGrid com dados filtrados por CST
/// </summary>
procedure PreencherStringGridPorCST(const AStringGrid: TStringGrid;
                                    const AGerenciador: TGerenciadorClassificacaoTributaria;
                                    const ACST: string);

/// <summary>
/// Preenche StringGrid com dados filtrados por Classificação
/// </summary>
procedure PreencherStringGridPorClassificacao(const AStringGrid: TStringGrid;
                                              const AGerenciador: TGerenciadorClassificacaoTributaria;
                                              const AClassificacao: string);

/// <summary>
/// Ajusta a largura das colunas automaticamente
/// </summary>
procedure AdjustarLarguraColunasStringGrid(const AStringGrid: TStringGrid);

implementation

constructor TGerenciadorClassificacaoTributaria.Create(const AArquivoJSON: string);
begin
  inherited Create;
  FArquivoJSON := AArquivoJSON;
  FListaClassificacoes := TListaClassificacoes.Create;
end;

destructor TGerenciadorClassificacaoTributaria.Destroy;
begin
  FListaClassificacoes.Free;
  inherited;
end;

function TGerenciadorClassificacaoTributaria.StringParaBoolean(const AValor: string): Boolean;
begin
  Result := SameText(AValor, 'Sim');
end;

function TGerenciadorClassificacaoTributaria.StringParaInteger(const AValor: string): Integer;
begin
  if AValor.IsEmpty then
    Result := 0
  else
    Result := StrToIntDef(AValor, 0);
end;

procedure TGerenciadorClassificacaoTributaria.CarregarDoJSON;
var
  JSONStr: string;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  JSONValue: TJSONValue;
  i: Integer;
  Classificacao: TClassificacaoTributaria;
  LFileName: string;
  Bytes: TBytes;
begin
  FListaClassificacoes.Clear;

  LFileName := FArquivoJSON;
  if not FileExists(LFileName) then
    raise Exception.Create('Arquivo JSON não encontrado: ' + LFileName);

  // Ler arquivo com codificação UTF-8
  try
    Bytes := TFile.ReadAllBytes(LFileName);
    JSONStr := TEncoding.UTF8.GetString(Bytes);
  except
    on E: Exception do
      raise Exception.Create('Erro ao ler arquivo: ' + E.Message);
  end;

  if JSONStr.IsEmpty then
    raise Exception.Create('Arquivo JSON está vazio');

  // Parse JSON
  try
    JSONValue := TJSONObject.ParseJSONValue(JSONStr);

    if not (JSONValue is TJSONArray) then
    begin
      JSONValue.Free;
      raise Exception.Create('Formato inválido: esperado um array JSON');
    end;

    JSONArray := JSONValue as TJSONArray;

    try
      for i := 0 to JSONArray.Count - 1 do
      begin
        JSONObject := JSONArray.Items[i] as TJSONObject;

        if Assigned(JSONObject) then
        begin
          FillChar(Classificacao, SizeOf(Classificacao), 0);

          Classificacao.CodigoSituacaoTributaria              := JSONObject.GetValue('Código da Situação Tributária').Value;
          Classificacao.DescricaoSituacaoTributaria           := JSONObject.GetValue('Descrição da Situação Tributária').Value;
          Classificacao.TributacaoRegular                     := StringParaBoolean(JSONObject.GetValue('Tributação Regular').Value);
          Classificacao.ReducaoBCCST                          := StringParaBoolean(JSONObject.GetValue('Redução BC CST').Value);
          Classificacao.ReducaoAliquota                       := StringParaBoolean(JSONObject.GetValue('Redução de Alíquota').Value);
          Classificacao.TransferenciaCredito                  := StringParaBoolean(JSONObject.GetValue('Transferência de Crédito').Value);
          Classificacao.Diferimento                           := StringParaBoolean(JSONObject.GetValue('Diferimento').Value);
          Classificacao.Monofasica                            := StringParaBoolean(JSONObject.GetValue('Monofásica').Value);
          Classificacao.CreditoPresumidoIBSZFM                := StringParaBoolean(JSONObject.GetValue('Crédito Presumido IBS Zona Franca de Manaus').Value);
          Classificacao.AjusteCompetencia                     := StringParaBoolean(JSONObject.GetValue('Ajuste de Competência').Value);
          Classificacao.CodigoClassificacaoTributaria         := JSONObject.GetValue('Código da Classificação Tributária').Value;
          Classificacao.DescricaoClassificacao                := JSONObject.GetValue('Descrição do Código da Classificação Tributária').Value;
          Classificacao.PercentualReducaoIBS                  := StringParaInteger(JSONObject.GetValue('Percentual Redução IBS').Value);
          Classificacao.PercentualReducaoCBS                  := StringParaInteger(JSONObject.GetValue('Percentual Redução CBS').Value);
          Classificacao.ReducaoBC                             := StringParaBoolean(JSONObject.GetValue('Redução BC').Value);
          Classificacao.CreditoPresumido                      := StringParaBoolean(JSONObject.GetValue('Crédito Presumido').Value);
          Classificacao.EstornoCredito                        := StringParaBoolean(JSONObject.GetValue('Estorno de Crédito').Value);
          Classificacao.TipoAliquota                          := JSONObject.GetValue('Tipo de Alíquota').Value;
          Classificacao.NFe                                   := StringParaBoolean(JSONObject.GetValue('NFe').Value);
          Classificacao.NFCe                                  := StringParaBoolean(JSONObject.GetValue('NFCe').Value);
          Classificacao.CTe                                   := StringParaBoolean(JSONObject.GetValue('CTe').Value);
          Classificacao.CTeOS                                 := StringParaBoolean(JSONObject.GetValue('CTe OS').Value);
          Classificacao.BPe                                   := StringParaBoolean(JSONObject.GetValue('BPe').Value);
          Classificacao.NF3e                                  := StringParaBoolean(JSONObject.GetValue('NF3e').Value);
          Classificacao.NFCom                                 := StringParaBoolean(JSONObject.GetValue('NFCom').Value);
          Classificacao.NFSE                                  := StringParaBoolean(JSONObject.GetValue('NFSE').Value);
          Classificacao.BPeTM                                 := StringParaBoolean(JSONObject.GetValue('BPe TM').Value);
          Classificacao.BPeTA                                 := StringParaBoolean(JSONObject.GetValue('BPe TA').Value);
          Classificacao.NFAg                                  := StringParaBoolean(JSONObject.GetValue('NFAg').Value);
          Classificacao.NFSVIA                                := StringParaBoolean(JSONObject.GetValue('NFSVIA').Value);
          Classificacao.NFABI                                 := StringParaBoolean(JSONObject.GetValue('NFABI').Value);
          Classificacao.NFGas                                 := StringParaBoolean(JSONObject.GetValue('NFGas').Value);
          Classificacao.DERE                                  := StringParaBoolean(JSONObject.GetValue('DERE').Value);
          Classificacao.NumeroAnexo                           := JSONObject.GetValue('Número do Anexo').Value;
          Classificacao.UrlLegislacao                         := JSONObject.GetValue('Url da Legislação').Value;

          FListaClassificacoes.Add(Classificacao);
        end;
      end;
    finally
      JSONValue.Free;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro ao processar JSON: ' + E.Message);
  end;
end;
procedure TGerenciadorClassificacaoTributaria.Carregar;
begin
  CarregarDoJSON;
end;

function TGerenciadorClassificacaoTributaria.ObterTotal: Integer;
begin
  Result := FListaClassificacoes.Count;
end;

function TGerenciadorClassificacaoTributaria.BuscarCSTporClasificacao(const ACodigoClassificacao: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to FListaClassificacoes.Count - 1 do
  begin
    if FListaClassificacoes[i].CodigoClassificacaoTributaria = ACodigoClassificacao then
    begin
      Result := FListaClassificacoes[i].CodigoSituacaoTributaria;
      Exit;
    end;
  end;
end;

function TGerenciadorClassificacaoTributaria.BuscarClassificacaoPorCST(const ACodigoCST: string): TList<string>;
var
  i: Integer;
begin
  Result := TList<string>.Create;
  for i := 0 to FListaClassificacoes.Count - 1 do
  begin
    if FListaClassificacoes[i].CodigoSituacaoTributaria = ACodigoCST then
      Result.Add(FListaClassificacoes[i].CodigoClassificacaoTributaria);
  end;
end;

function TGerenciadorClassificacaoTributaria.BuscarRegistroPorClasificacao(const ACodigoClassificacao: string): TClassificacaoTributaria;
var
  i: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  for i := 0 to FListaClassificacoes.Count - 1 do
  begin
    if FListaClassificacoes[i].CodigoClassificacaoTributaria = ACodigoClassificacao then
    begin
      Result := FListaClassificacoes[i];
      Exit;
    end;
  end;
end;

function TGerenciadorClassificacaoTributaria.BuscarRegistrosPorCST(const ACodigoCST: string): TListaClassificacoes;
var
  i: Integer;
  Temp: TListaClassificacoes;
begin
  Temp := TListaClassificacoes.Create;
  for i := 0 to FListaClassificacoes.Count - 1 do
  begin
    if FListaClassificacoes[i].CodigoSituacaoTributaria = ACodigoCST then
      Temp.Add(FListaClassificacoes[i]);
  end;
  Result := Temp;
end;

function TGerenciadorClassificacaoTributaria.ObterTodos: TListaClassificacoes;
begin
  Result := FListaClassificacoes;
end;

function TGerenciadorClassificacaoTributaria.ObterDescricaoFormatada(const AClassificacao: TClassificacaoTributaria): string;
begin
  Result := Format(
    'CST: %s - %s'#13#10 +
    'Classificação: %s - %s'#13#10 +
    'IBS: %d%% | CBS: %d%%'#13#10 +
    'Diferimento: %s | Monofásica: %s'#13#10 +
    'NFe: %s | NFCe: %s | CTe: %s'#13#10 +
    'Legislação: %s',
    [
      AClassificacao.CodigoSituacaoTributaria,
      AClassificacao.DescricaoSituacaoTributaria,
      AClassificacao.CodigoClassificacaoTributaria,
      AClassificacao.DescricaoClassificacao,
      AClassificacao.PercentualReducaoIBS,
      AClassificacao.PercentualReducaoCBS,
      IfThen(AClassificacao.Diferimento, 'S', 'N'),
      IfThen(AClassificacao.Monofasica, 'Sim', 'N'),
      IfThen(AClassificacao.NFe, 'S', 'N'),
      IfThen(AClassificacao.NFCe, 'S', 'N'),
      IfThen(AClassificacao.CTe, 'S', 'N'),
      AClassificacao.UrlLegislacao
    ]
  );
end;

/// <summary>
/// Preenche StringGrid com todos os dados das classificações tributárias
/// </summary>
procedure PreencherStringGridCompleto(const AStringGrid: TStringGrid;
                                      const AGerenciador: TGerenciadorClassificacaoTributaria);
var
  i: Integer;
  Classificacao: TClassificacaoTributaria;
  Lista: TListaClassificacoes;
begin
  if not Assigned(AStringGrid) or not Assigned(AGerenciador) then
    raise Exception.Create('StringGrid ou Gerenciador não atribuído');

  AStringGrid.BeginUpdate;
  try
    // Configurar colunas
    AStringGrid.ColCount := 15;
    AStringGrid.RowCount := AGerenciador.ObterTotal + 1;

    // Cabeçalho
    AStringGrid.Cells[0, 0]  := 'CST';
    AStringGrid.Cells[1, 0]  := 'Descrição CST';
    AStringGrid.Cells[2, 0]  := 'Classificação';
    AStringGrid.Cells[3, 0]  := 'Descrição Classificação';
    AStringGrid.Cells[4, 0]  := 'IBS %';
    AStringGrid.Cells[5, 0]  := 'CBS %';
    AStringGrid.Cells[6, 0]  := 'Diferimento';
    AStringGrid.Cells[7, 0]  := 'Monofásica';
    AStringGrid.Cells[8, 0]  := 'NFe';
    AStringGrid.Cells[9, 0]  := 'NFCe';
    AStringGrid.Cells[10, 0] := 'CTe';
    AStringGrid.Cells[11, 0] := 'Crédito Presumido';
    AStringGrid.Cells[12, 0] := 'Tipo Alíquota';
    AStringGrid.Cells[13, 0] := 'Anexo';
    AStringGrid.Cells[14, 0] := 'Legislação';

    // Dados
    Lista := AGerenciador.ObterTodos;
    for i := 0 to Lista.Count - 1 do
    begin
      Classificacao := Lista[i];

      AStringGrid.Cells[0, i + 1]  := Classificacao.CodigoSituacaoTributaria;
      AStringGrid.Cells[1, i + 1]  := Classificacao.DescricaoSituacaoTributaria;
      AStringGrid.Cells[2, i + 1]  := Classificacao.CodigoClassificacaoTributaria;
      AStringGrid.Cells[3, i + 1]  := Classificacao.DescricaoClassificacao;
      AStringGrid.Cells[4, i + 1]  := IntToStr(Classificacao.PercentualReducaoIBS);
      AStringGrid.Cells[5, i + 1]  := IntToStr(Classificacao.PercentualReducaoCBS);
      AStringGrid.Cells[6, i + 1]  := IfThen(Classificacao.Diferimento, 'S', 'N');
      AStringGrid.Cells[7, i + 1]  := IfThen(Classificacao.Monofasica, 'S', 'N');
      AStringGrid.Cells[8, i + 1]  := IfThen(Classificacao.NFe, 'S', 'N');
      AStringGrid.Cells[9, i + 1]  := IfThen(Classificacao.NFCe, 'S', 'N');
      AStringGrid.Cells[10, i + 1] := IfThen(Classificacao.CTe, 'S', 'N');
      AStringGrid.Cells[11, i + 1] := IfThen(Classificacao.CreditoPresumido, 'S', 'N');
      AStringGrid.Cells[12, i + 1] := Classificacao.TipoAliquota;
      AStringGrid.Cells[13, i + 1] := Classificacao.NumeroAnexo;
      AStringGrid.Cells[14, i + 1] := Classificacao.UrlLegislacao;
    end;

    // Ajustar largura das colunas
    AdjustarLarguraColunasStringGrid(AStringGrid);

  finally
    AStringGrid.EndUpdate;
  end;
end;

/// <summary>
/// Preenche StringGrid com dados filtrados por CST
/// </summary>
procedure PreencherStringGridPorCST(const AStringGrid: TStringGrid;
                                    const AGerenciador: TGerenciadorClassificacaoTributaria;
                                    const ACST: string);
var
  i: Integer;
  Classificacao: TClassificacaoTributaria;
  Lista: TListaClassificacoes;
begin
  if not Assigned(AStringGrid) or not Assigned(AGerenciador) then
    raise Exception.Create('StringGrid ou Gerenciador não atribuído');

  AStringGrid.BeginUpdate;
  try
    AStringGrid.ColCount := 15;

    Lista := AGerenciador.BuscarRegistrosPorCST(ACST);
    if Lista.Count = 0 then
    begin
      AStringGrid.RowCount := 2;
      ShowMessage('Nenhum registro encontrado para CST: ' + ACST);
      Exit;
    end;

    AStringGrid.RowCount := Lista.Count + 1;

    // Cabeçalho
    AStringGrid.Cells[0, 0]  := 'CST';
    AStringGrid.Cells[1, 0]  := 'Descrição CST';
    AStringGrid.Cells[2, 0]  := 'Classificação';
    AStringGrid.Cells[3, 0]  := 'Descrição Classificação';
    AStringGrid.Cells[4, 0]  := 'IBS %';
    AStringGrid.Cells[5, 0]  := 'CBS %';
    AStringGrid.Cells[6, 0]  := 'Diferimento';
    AStringGrid.Cells[7, 0]  := 'Monofásica';
    AStringGrid.Cells[8, 0]  := 'NFe';
    AStringGrid.Cells[9, 0]  := 'NFCe';
    AStringGrid.Cells[10, 0] := 'CTe';
    AStringGrid.Cells[11, 0] := 'Crédito Presumido';
    AStringGrid.Cells[12, 0] := 'Tipo Alíquota';
    AStringGrid.Cells[13, 0] := 'Anexo';
    AStringGrid.Cells[14, 0] := 'Legislação';

    // Dados
    for i := 0 to Lista.Count - 1 do
    begin
      Classificacao := Lista[i];

      AStringGrid.Cells[0, i + 1]  := Classificacao.CodigoSituacaoTributaria;
      AStringGrid.Cells[1, i + 1]  := Classificacao.DescricaoSituacaoTributaria;
      AStringGrid.Cells[2, i + 1]  := Classificacao.CodigoClassificacaoTributaria;
      AStringGrid.Cells[3, i + 1]  := Classificacao.DescricaoClassificacao;
      AStringGrid.Cells[4, i + 1]  := IntToStr(Classificacao.PercentualReducaoIBS);
      AStringGrid.Cells[5, i + 1]  := IntToStr(Classificacao.PercentualReducaoCBS);
      AStringGrid.Cells[6, i + 1]  := IfThen(Classificacao.Diferimento, 'S', 'N');
      AStringGrid.Cells[7, i + 1]  := IfThen(Classificacao.Monofasica, 'S', 'N');
      AStringGrid.Cells[8, i + 1]  := IfThen(Classificacao.NFe, 'S', 'N');
      AStringGrid.Cells[9, i + 1]  := IfThen(Classificacao.NFCe, 'S', 'N');
      AStringGrid.Cells[10, i + 1] := IfThen(Classificacao.CTe, 'S', 'N');
      AStringGrid.Cells[11, i + 1] := IfThen(Classificacao.CreditoPresumido, 'S', 'N');
      AStringGrid.Cells[12, i + 1] := Classificacao.TipoAliquota;
      AStringGrid.Cells[13, i + 1] := Classificacao.NumeroAnexo;
      AStringGrid.Cells[14, i + 1] := Classificacao.UrlLegislacao;
    end;

    AdjustarLarguraColunasStringGrid(AStringGrid);
    Lista.Free;

  finally
    AStringGrid.EndUpdate;
  end;
end;

/// <summary>
/// Preenche StringGrid com dados filtrados por Classificação
/// </summary>
procedure PreencherStringGridPorClassificacao(const AStringGrid: TStringGrid;
                                              const AGerenciador: TGerenciadorClassificacaoTributaria;
                                              const AClassificacao: string);
var
  Reg: TClassificacaoTributaria;
begin
  if not Assigned(AStringGrid) or not Assigned(AGerenciador) then
    raise Exception.Create('StringGrid ou Gerenciador não atribuído');

  AStringGrid.BeginUpdate;
  try
    AStringGrid.ColCount := 15;
    AStringGrid.RowCount := 2;

    Reg := AGerenciador.BuscarRegistroPorClasificacao(AClassificacao);

    if Reg.CodigoClassificacaoTributaria.IsEmpty then
    begin
      ShowMessage('Nenhum registro encontrado para classificação: ' + AClassificacao);
      Exit;
    end;

    // Cabeçalho
    AStringGrid.Cells[0, 0]  := 'CST';
    AStringGrid.Cells[1, 0]  := 'Descrição CST';
    AStringGrid.Cells[2, 0]  := 'Classificação';
    AStringGrid.Cells[3, 0]  := 'Descrição Classificação';
    AStringGrid.Cells[4, 0]  := 'IBS %';
    AStringGrid.Cells[5, 0]  := 'CBS %';
    AStringGrid.Cells[6, 0]  := 'Diferimento';
    AStringGrid.Cells[7, 0]  := 'Monofásica';
    AStringGrid.Cells[8, 0]  := 'NFe';
    AStringGrid.Cells[9, 0]  := 'NFCe';
    AStringGrid.Cells[10, 0] := 'CTe';
    AStringGrid.Cells[11, 0] := 'Crédito Presumido';
    AStringGrid.Cells[12, 0] := 'Tipo Alíquota';
    AStringGrid.Cells[13, 0] := 'Anexo';
    AStringGrid.Cells[14, 0] := 'Legislação';

    // Dados
    AStringGrid.Cells[0, 1]  := Reg.CodigoSituacaoTributaria;
    AStringGrid.Cells[1, 1]  := Reg.DescricaoSituacaoTributaria;
    AStringGrid.Cells[2, 1]  := Reg.CodigoClassificacaoTributaria;
    AStringGrid.Cells[3, 1]  := Reg.DescricaoClassificacao;
    AStringGrid.Cells[4, 1]  := IntToStr(Reg.PercentualReducaoIBS);
    AStringGrid.Cells[5, 1]  := IntToStr(Reg.PercentualReducaoCBS);
    AStringGrid.Cells[6, 1]  := IfThen(Reg.Diferimento, 'S', 'N');
    AStringGrid.Cells[7, 1]  := IfThen(Reg.Monofasica, 'S', 'N');
    AStringGrid.Cells[8, 1]  := IfThen(Reg.NFe, 'S', 'N');
    AStringGrid.Cells[9, 1]  := IfThen(Reg.NFCe, 'S', 'N');
    AStringGrid.Cells[10, 1] := IfThen(Reg.CTe, 'S', 'N');
    AStringGrid.Cells[11, 1] := IfThen(Reg.CreditoPresumido, 'S', 'N');
    AStringGrid.Cells[12, 1] := Reg.TipoAliquota;
    AStringGrid.Cells[13, 1] := Reg.NumeroAnexo;
    AStringGrid.Cells[14, 1] := Reg.UrlLegislacao;

    AdjustarLarguraColunasStringGrid(AStringGrid);

  finally
    AStringGrid.EndUpdate;
  end;
end;

/// <summary>
/// Ajusta a largura das colunas automaticamente
/// </summary>
procedure AdjustarLarguraColunasStringGrid(const AStringGrid: TStringGrid);
var
  i: Integer;
begin
  for i := 0 to AStringGrid.ColCount - 1 do
  begin
    AStringGrid.ColWidths[i] := 120;
  end;
end;

end.
