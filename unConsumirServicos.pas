unit unConsumirServicos;

interface

uses System.Classes, REST.Json, IdHTTP, System.Json, IdSSLOpenSSL, SysUtils;

type
  TConsumirServico = class
    public
      class function Consumir(url: String): TJSONObject;
  end;

implementation

{ TServico }

class function TConsumirServico.Consumir(url: String): TJSONObject;
var
  retorno : TStringStream;
  http: TIdHTTP;
  handler: TIdSSLIOHandlerSocketOpenSSL;
begin
  retorno := TStringStream.Create();
  handler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  http := TIdHttp.Create(nil);
  Result:= nil;
  try
    http.ConnectTimeout := 5000;
    http.ReadTimeout := 5000;
    http.MaxAuthRetries := 0;
    http.HTTPOptions := [hoInProcessAuth];
    http.IOHandler := handler;
    http.Request.CustomHeaders.Clear;
    http.Request.BasicAuthentication := true;
    http.Request.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36';

    try
      http.GET(url, Retorno);
      if (http.ResponseCode = 200) and
         (not(Utf8ToAnsi(retorno.DataString) = '{'#$A'  "erro": true'#$A'}')) then
        Result:= TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes( Utf8ToAnsi(retorno.DataString)), 0) as TJSONObject;
    except
      Result:= nil;
    end;
  finally
    FreeAndNil(retorno);
    FreeAndNil(handler);
    FreeAndNil(http);
  end;
end;

end.
