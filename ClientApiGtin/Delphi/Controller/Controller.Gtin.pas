unit Controller.Gtin;

interface

uses
  System.Classes
  , System.SysUtils

  , System.JSON

  , IdHTTP
  , IdSSLOpenSSL
  , IdCoderMIME
  ;


const
  VERSAO_API  = 'v3';
  VERSAO_DEMO = '3.0';

  TITLE = 'CLIENT API GTIN by: OSCBR - Open Source Community Brasil';

  // O firewall da hospedagem recusa (406) POST com o User-Agent padrão do Indy,
  // "Mozilla/3.0 (compatible; Indy Library)". Acrescentar texto a ele não basta:
  // é preciso trocá-lo inteiro.
  USER_AGENT = 'ClientAPIGtin-OSCBR/' + VERSAO_DEMO;

  TIMEOUT = 10000;

  // As rotas antigas (/oauth/token, /api/gtin/infor e /api/gtin/img) foram
  // removidas da plataforma em 11/09/2026 e hoje respondem 404.
  URL_BASE                 = 'https://gtin.rscsistemas.com.br';
  URL_API                  = URL_BASE + '/api/' + VERSAO_API;

  ENDPOINT_OAUTH_TOKEN     = URL_API  + '/oauth/token';
  ENDPOINT_REFRESH_TOKEN   = URL_BASE + '/api/auth/refresh';
  ENDPOINT_GTIN            = URL_API  + '/gtin';

  GTIN_CONSULTAR           = ENDPOINT_GTIN + '/{gtin}';
  GTIN_IMAGEM              = ENDPOINT_GTIN + '/{gtin}/image';

type

  TTokenGtin = record
    AccessToken : string;
    RefreshToken: string;
    ExpiresIn   : Integer; // segundos de validade do AccessToken
  end;

  TControllerGtin = class
    private
      class function CriarHTTP: TIdHTTP;
      class function LerToken(const Resposta: string; out Token: TTokenGtin; out Erro: string): Boolean;
    public
      class function JsonTexto(Obj: TJSONObject; const Nome: string): string;
      class function MensagemErro(E: Exception): string;
      class function ValidarGTIN(const GTIN: string; out Erro: string): Boolean;

      class function GetToken(const Username, Password: string; out Token: TTokenGtin; out Erro: string): Boolean;
      class function RenovarToken(const RefreshToken: string; out Token: TTokenGtin; out Erro: string): Boolean;
      class function GetGTINInfo(const GTIN, AccessToken: string; out Infor, Erro: string): Boolean;
      class function GetGTINImagem(const GTIN, AccessToken: string; Imagem: TStream; out Erro: string): Boolean;

  end;

implementation

{ TControllerGtin }

class function TControllerGtin.CriarHTTP: TIdHTTP;
var
  SSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := TIdHTTP.Create(nil);

  // Configuração do IOHandler SSL (liberado junto com o TIdHTTP, que é o dono)
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(Result);
  SSL.SSLOptions.Method := sslvTLSv1_2;
  SSL.SSLOptions.Mode   := sslmClient;
  Result.IOHandler := SSL;

  Result.ConnectTimeout := TIMEOUT;
  Result.ReadTimeout    := TIMEOUT;

  Result.Request.Clear;
  Result.Request.BasicAuthentication := False;
  Result.Request.Accept              := 'application/json';
  Result.Request.AcceptEncoding      := '';
  Result.Request.UserAgent           := USER_AGENT;
end;

class function TControllerGtin.JsonTexto(Obj: TJSONObject; const Nome: string): string;
var
  Valor: TJSONValue;
begin
  // Campos ausentes ou null (ex.: dh_update) viram texto vazio
  Result := '';
  if Obj = nil then
    Exit;

  Valor := Obj.GetValue(Nome);
  if (Valor <> nil) and not (Valor is TJSONNull) then
    Result := Valor.Value;
end;

class function TControllerGtin.MensagemErro(E: Exception): string;
var
  Erro : EIdHTTPProtocolException;
  Json : TJSONValue;
  Texto: string;
begin
  if not (E is EIdHTTPProtocolException) then
    Exit(E.Message);

  Erro   := EIdHTTPProtocolException(E);
  Result := Format('HTTP %d', [Erro.ErrorCode]);

  // A API responde os erros em JSON: {"mensagem": "..."} ou {"erro": "..."},
  // às vezes com "motivo" e "ajuda" (link da página que explica o erro).
  Json := TJSONObject.ParseJSONValue(Erro.ErrorMessage);
  try
    if Json is TJSONObject then
    begin
      Texto := JsonTexto(TJSONObject(Json), 'mensagem');
      if Texto = '' then
        Texto := JsonTexto(TJSONObject(Json), 'erro');
      if Texto <> '' then
        Result := Result + ' - ' + Texto;

      Texto := JsonTexto(TJSONObject(Json), 'ajuda');
      if Texto <> '' then
        Result := Result + sLineBreak + 'Ajuda: ' + Texto;
    end
    else if Erro.ErrorCode = 406 then
      // Página HTML do ModSecurity: a requisição nem chegou na API
      Result := Result + ' - requisição recusada pelo firewall da hospedagem.' + sLineBreak
              + 'Envie um User-Agent próprio e Content-Length: 0 nos POST sem corpo.'
    else
      Result := Result + ' - ' + Erro.Message;
  finally
    Json.Free;
  end;
end;

class function TControllerGtin.ValidarGTIN(const GTIN: string; out Erro: string): Boolean;
var
  I, Soma, Peso: Integer;
begin
  // Mesma regra da API (GS1): somente dígitos, 8, 12, 13 ou 14 posições, não
  // todo zero e dígito verificador correto. Validar antes de consultar evita a
  // suspensão (429) por envio repetido de GTIN inválido.
  Result := False;
  Erro   := 'GTIN inválido: informe somente dígitos, com 8, 12, 13 ou 14 posições (e não todo zero).';

  case Length(GTIN) of
    8, 12, 13, 14: ;
  else
    Exit;
  end;

  for I := 1 to Length(GTIN) do
    if not CharInSet(GTIN[I], ['0'..'9']) then
      Exit;

  if GTIN = StringOfChar('0', Length(GTIN)) then
    Exit;

  // Módulo 10, pesos 3 e 1 alternados da direita para a esquerda
  Soma := 0;
  Peso := 3;
  for I := Length(GTIN) - 1 downto 1 do
  begin
    Soma := Soma + (Ord(GTIN[I]) - Ord('0')) * Peso;
    Peso := 4 - Peso;
  end;

  if ((10 - (Soma mod 10)) mod 10) <> (Ord(GTIN[Length(GTIN)]) - Ord('0')) then
  begin
    Erro := 'GTIN inválido: dígito verificador não confere.';
    Exit;
  end;

  Erro   := '';
  Result := True;
end;

class function TControllerGtin.LerToken(const Resposta: string;
  out Token: TTokenGtin; out Erro: string): Boolean;
var
  JSONData: TJSONValue;
begin
  Result := False;
  Erro   := '';
  Token  := Default(TTokenGtin);

  JSONData := TJSONObject.ParseJSONValue(Resposta);
  try
    if not (JSONData is TJSONObject) then
    begin
      Erro := 'Resposta inesperada da API ao emitir o token.';
      Exit;
    end;

    Token.AccessToken  := JsonTexto(TJSONObject(JSONData), 'access_token');
    if Token.AccessToken = '' then
      Token.AccessToken := JsonTexto(TJSONObject(JSONData), 'token');
    Token.RefreshToken := JsonTexto(TJSONObject(JSONData), 'refresh_token');
    Token.ExpiresIn    := StrToIntDef(JsonTexto(TJSONObject(JSONData), 'expires_in'), 0);

    Result := Token.AccessToken <> '';
    if not Result then
      Erro := 'A API não retornou o token.';
  finally
    JSONData.Free;
  end;
end;

class function TControllerGtin.GetToken(const Username,
  Password: string; out Token: TTokenGtin; out Erro: string): Boolean;
var
  HTTPClient: TIdHTTP;
  Stream    : TStringStream;
  Response  : string;
begin
  Result := False;
  Token  := Default(TTokenGtin);
  Erro   := '';

  // Corpo vazio: o Indy envia Content-Length: 0 (sem ele o firewall responde 406)
  Stream      :=  TStringStream.Create('');
  HTTPClient  :=  CriarHTTP;
  try
    // Codifica as credenciais (username:senha) em Base64 para o Basic Auth
    HTTPClient.Request.CustomHeaders.Values['Authorization'] :=
      'Basic ' + TIdEncoderMIME.EncodeString(Username + ':' + Password);

    try
      Response := HTTPClient.Post(ENDPOINT_OAUTH_TOKEN, Stream);
      Result   := LerToken(Response, Token, Erro);
    except
      on E: Exception do
        Erro := MensagemErro(E);
    end;
  finally
    Stream.Free;
    HTTPClient.Free;
  end;
end;

class function TControllerGtin.RenovarToken(const RefreshToken: string;
  out Token: TTokenGtin; out Erro: string): Boolean;
var
  HTTPClient: TIdHTTP;
  Corpo     : TJSONObject;
  Stream    : TStringStream;
  Response  : string;
begin
  // O refresh token só vale uma vez: guarde o novo par devolvido. Reutilizar um
  // refresh já consumido encerra a sessão e exige novo GetToken.
  Result := False;
  Token  := Default(TTokenGtin);
  Erro   := '';

  Corpo := TJSONObject.Create;
  try
    Corpo.AddPair('refresh_token', RefreshToken);
    Stream := TStringStream.Create(Corpo.ToString, TEncoding.UTF8);
  finally
    Corpo.Free;
  end;

  HTTPClient := CriarHTTP;
  try
    HTTPClient.Request.ContentType := 'application/json';

    try
      Response := HTTPClient.Post(ENDPOINT_REFRESH_TOKEN, Stream);
      Result   := LerToken(Response, Token, Erro);
    except
      on E: Exception do
        Erro := MensagemErro(E);
    end;
  finally
    Stream.Free;
    HTTPClient.Free;
  end;
end;

class function TControllerGtin.GetGTINInfo(const GTIN,
  AccessToken: string; out Infor, Erro: string): Boolean;
var
  sURL      : String;
  vIdHTTP   : TIdHTTP;
begin
  Result  :=  False;
  Infor   :=  '';
  Erro    :=  '';

  sURL := StringReplace(GTIN_CONSULTAR, '{gtin}', GTIN, [rfReplaceAll]);

  vIdHTTP := CriarHTTP;
  try
    vIdHTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + AccessToken;

    try
      Infor   :=  vIdHTTP.Get(sURL);
      Result  :=  True;
    except
      on E: Exception do
        Erro := MensagemErro(E);
    end;
  finally
    vIdHTTP.Free;
  end;
end;

class function TControllerGtin.GetGTINImagem(const GTIN, AccessToken: string;
  Imagem: TStream; out Erro: string): Boolean;
var
  sURL      : String;
  vIdHTTP   : TIdHTTP;
begin
  // Produto sem foto retorna 200 com a imagem padrão "sem imagem".
  // O corpo pode ser PNG ou JPEG: identifique pelo conteúdo, não pela extensão.
  Result := False;
  Erro   := '';
  Imagem.Size := 0;

  sURL := StringReplace(GTIN_IMAGEM, '{gtin}', GTIN, [rfReplaceAll]);

  vIdHTTP := CriarHTTP;
  try
    vIdHTTP.Request.Accept := 'image/*, application/json';
    vIdHTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + AccessToken;

    try
      vIdHTTP.Get(sURL, Imagem);

      Result := Imagem.Size > 0;
      if Result then
        Imagem.Position := 0
      else
        Erro := 'A API não retornou a imagem.';
    except
      on E: Exception do
      begin
        Imagem.Size := 0;
        Erro := MensagemErro(E);
      end;
    end;
  finally
    vIdHTTP.Free;
  end;
end;

end.
