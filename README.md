# 📊 Percentuais da Reforma Tributária - API tributos.gov.br

<img width="367" height="212" alt="image" src="https://github.com/user-attachments/assets/d396dff8-a072-4403-bde3-03b6665d2352" />


```procedure TfrmCalculadoraRT.FormCreate(Sender: TObject);
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
end;```
