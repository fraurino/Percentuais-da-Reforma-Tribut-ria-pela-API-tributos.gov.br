unit uCalculadoraTributosAPI;

interface

uses
  System.SysUtils, System.Net.HttpClient, System.Net.URLClient, System.JSON, System.Classes;

type
  EAtributoInvalido = class(Exception);
  ERequisicaoHTTP = class(Exception);

  TAliquotaDados = record
    AliquotaReferencia: Double;
    AliquotaPropria: Double;
    FormaAplicacao: string;
  end;

  TCalculadoraTributosAPI = class
  private
    FHttp: THTTPClient;
    FBaseURL: string;
    function ExecutarGET(const AEndpoint: string): string;
    function ParseAliquotaJSON(const JsonStr: string): TAliquotaDados;
  public
    constructor Create;
    destructor Destroy; override;

    function GetAliquotaCBS(const Data: string): TAliquotaDados;
    function GetAliquotaIBSUF(const CodigoUF: Integer; const Data: string): TAliquotaDados;
    function GetAliquotaIBSMunicipio(const CodigoMunicipio: Integer; const Data: string): TAliquotaDados;

    function GetResumoTributos(const CodigoUF, CodigoMunicipio: Integer; const Data: string): string;
  end;

implementation

{ TCalculadoraTributosAPI }

constructor TCalculadoraTributosAPI.Create;
begin
  inherited Create;
  FHttp := THTTPClient.Create;
  FBaseURL := 'https://piloto-cbs.tributos.gov.br/servico/calculadora-consumo/api/calculadora/dados-abertos/';
  FHttp.ConnectionTimeout := 5000;
  FHttp.ResponseTimeout := 10000;
end;

destructor TCalculadoraTributosAPI.Destroy;
begin
  FHttp.Free;
  inherited;
end;

function TCalculadoraTributosAPI.ExecutarGET(const AEndpoint: string): string;
var
  LResponse: IHTTPResponse;
begin
  try
    LResponse := FHttp.Get(AEndpoint);
    if LResponse.StatusCode <> 200 then
      raise ERequisicaoHTTP.CreateFmt('Erro HTTP %d: %s', [LResponse.StatusCode, LResponse.StatusText]);

    Result := LResponse.ContentAsString(TEncoding.UTF8).Trim;
  except
    on E: Exception do
      raise ERequisicaoHTTP.Create('Falha na requisição: ' + E.Message);
  end;
end;

function TCalculadoraTributosAPI.ParseAliquotaJSON(const JsonStr: string): TAliquotaDados;
var
  JsonText: string;
  Json: TJSONObject;
begin
  // Limpa caracteres inválidos no final, como ponto ou espaço
  JsonText := JsonStr.Trim;
  if JsonText.EndsWith('.') then
    JsonText := JsonText.Substring(0, JsonText.Length - 1);

  Json := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
  try
    if not Assigned(Json) then
      raise EAtributoInvalido.Create('JSON inválido retornado pela API.');

    Result.AliquotaReferencia := Json.GetValue<Double>('aliquotaReferencia', 0.0);
    Result.AliquotaPropria := Json.GetValue<Double>('aliquotaPropria', Result.AliquotaReferencia);
    Result.FormaAplicacao := Json.GetValue<string>('formaAplicacao', '---');
  finally
    Json.Free;
  end;
end;

function TCalculadoraTributosAPI.GetAliquotaCBS(const Data: string): TAliquotaDados;
var
  URL: string;
begin
  URL := FBaseURL + 'aliquota-uniao?data=' + Data;
  Result := ParseAliquotaJSON(ExecutarGET(URL));
end;

function TCalculadoraTributosAPI.GetAliquotaIBSUF(const CodigoUF: Integer; const Data: string): TAliquotaDados;
var
  URL: string;
begin
  URL := FBaseURL + Format('aliquota-uf?codigoUf=%d&data=%s', [CodigoUF, Data]);
  Result := ParseAliquotaJSON(ExecutarGET(URL));
end;

function TCalculadoraTributosAPI.GetAliquotaIBSMunicipio(const CodigoMunicipio: Integer; const Data: string): TAliquotaDados;
var
  URL: string;
begin
  URL := FBaseURL + Format('aliquota-municipio?codigoMunicipio=%d&data=%s', [CodigoMunicipio, Data]);
  Result := ParseAliquotaJSON(ExecutarGET(URL));
end;

function TCalculadoraTributosAPI.GetResumoTributos(const CodigoUF, CodigoMunicipio: Integer; const Data: string): string;
var
  CBS, IBSUF, IBSMun: TAliquotaDados;
begin
  CBS     := GetAliquotaCBS(Data);
  IBSUF   := GetAliquotaIBSUF(CodigoUF, Data);
  IBSMun  := GetAliquotaIBSMunicipio(CodigoMunicipio, Data);

  Result :=
    Format(
      '📊 CBS (União): %.2f%% '#13#10 +
      '🏛 IBS UF (%d): %.2f%% '#13#10 +
      '🏙 IBS MUN (%d): %.2f%% ',
      [
        CBS.AliquotaPropria,
        CodigoUF, IBSUF.AliquotaPropria,
        CodigoMunicipio, IBSMun.AliquotaPropria
      ]
    );
end;

end.

