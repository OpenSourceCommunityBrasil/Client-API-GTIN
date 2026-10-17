{####################################################################################################################
                              OSCBR -> Open Source Community Brasil  -  https://oscbr.com.br
####################################################################################################################
                                                  API GTIN
####################################################################################################################
    Owner.....: Roniery Santos Cardoso / OSCBR
    youtube...: https://www.youtube.com/@RSC_SISTEMA
    Github....: https://github.com/OpenSourceCommunityBrasil/demo-API-GTIN
####################################################################################################################

####################################################################################################################
OpenSourceCommunityBrasil/demo-API-GTIN está licenciado sob a Licença Pública Geral GNU v3.0

As permissões desta forte licença copyleft estão condicionadas à disponibilização do código-fonte completo de obras
licenciadas e modificações, que incluem obras maiores usando uma obra licenciada, sob a mesma licença. Os avisos de
copyright e licença devem ser preservados. Os colaboradores fornecem uma concessão expressa de direitos de patente.

Permissões
 Uso comercial
 Modificação
 Distribuição
 Uso de patente
 Uso privado

Limitações
 Responsabilidade
 garantia

Condições
 Aviso de licença e direitos autorais
 mudanças de estado
 Divulgue a fonte
 Mesma licença
####################################################################################################################
}

unit Controller.Gtin;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, fpjson, jsonparser, opensslsockets
  , base64;

const
  VERSAO_API  = 'v3';
  VERSAO_DEMO = '3.0';

  TITLE = 'CLIENT API GTIN by: OSCBR - Open Source Community Brasil';

  // O firewall da hospedagem recusa (406) User-Agents genéricos de bibliotecas
  // HTTP: identifique o seu sistema.
  USER_AGENT = 'ClientAPIGtin-OSCBR/' + VERSAO_DEMO;

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

    { TControllerGtin }

    TControllerGtin = class
    private
      class function CriarHTTP: TFPHTTPClient;
      class function Executar(HTTPClient: TFPHTTPClient; const Metodo, URL: string;
        Resposta: TStream; out Erro: string): Boolean;
      class function MensagemErro(Status: Integer; const Corpo: string): string;
      class function LerToken(const Resposta: string; out Token: TTokenGtin; out Erro: string): Boolean;
    public
      class function JsonTexto(JSONData: TJSONData; const Nome: string): string;
      class function ValidarGTIN(const GTIN: string; out Erro: string): Boolean;

      class function GetToken(const Username, Password: string; out Token: TTokenGtin; out Erro: string): Boolean;
      class function RenovarToken(const RefreshToken: string; out Token: TTokenGtin; out Erro: string): Boolean;
      class function GetGTINInfo(const GTIN, AccessToken: string; out Infor, Erro: string): Boolean;
      class function GetGTINImagem(const GTIN, AccessToken: string; Imagem: TStream; out Erro: string): Boolean;
    end;

implementation

function StreamParaTexto(Stream: TStream): string;
begin
  Result := '';
  if Stream.Size = 0 then
    Exit;

  SetLength(Result, Stream.Size);
  Stream.Position := 0;
  Stream.ReadBuffer(Result[1], Stream.Size);
end;

{ TControllerGtin }

class function TControllerGtin.CriarHTTP: TFPHTTPClient;
begin
  Result := TFPHTTPClient.Create(nil);
  Result.AddHeader('User-Agent', USER_AGENT);
  Result.AddHeader('Accept', 'application/json');
end;

class function TControllerGtin.Executar(HTTPClient: TFPHTTPClient;
  const Metodo, URL: string; Resposta: TStream; out Erro: string): Boolean;
begin
  Erro := '';
  try
    // [] = aceita qualquer status; o resultado é conferido logo abaixo
    HTTPClient.HTTPMethod(Metodo, URL, Resposta, []);
  except
    on E: Exception do
    begin
      Erro := E.Message;
      Exit(False);
    end;
  end;

  Result := HTTPClient.ResponseStatusCode = 200;
  if not Result then
    Erro := MensagemErro(HTTPClient.ResponseStatusCode, StreamParaTexto(Resposta));
end;

class function TControllerGtin.JsonTexto(JSONData: TJSONData; const Nome: string): string;
var
  Valor: TJSONData;
begin
  // Campos ausentes ou null (ex.: dh_update) viram texto vazio
  Result := '';
  if not (JSONData is TJSONObject) then
    Exit;

  Valor := TJSONObject(JSONData).Find(Nome);
  if (Valor <> nil) and not Valor.IsNull then
    Result := Valor.AsString;
end;

class function TControllerGtin.MensagemErro(Status: Integer; const Corpo: string): string;
var
  JSONData: TJSONData;
  Texto   : string;
begin
  Result := Format('HTTP %d', [Status]);

  // A API responde os erros em JSON: {"mensagem": "..."} ou {"erro": "..."},
  // às vezes com "motivo" e "ajuda" (link da página que explica o erro).
  try
    JSONData := GetJSON(Corpo);
  except
    JSONData := nil;
  end;

  try
    if JSONData is TJSONObject then
    begin
      Texto := JsonTexto(JSONData, 'mensagem');
      if Texto = '' then
        Texto := JsonTexto(JSONData, 'erro');
      if Texto <> '' then
        Result := Result + ' - ' + Texto;

      Texto := JsonTexto(JSONData, 'ajuda');
      if Texto <> '' then
        Result := Result + LineEnding + 'Ajuda: ' + Texto;
    end
    else if Status = 406 then
      // Página HTML do ModSecurity: a requisição nem chegou na API
      Result := Result + ' - requisição recusada pelo firewall da hospedagem.' + LineEnding
              + 'Envie um User-Agent próprio e Content-Length: 0 nos POST sem corpo.';
  finally
    JSONData.Free;
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
    if not (GTIN[I] in ['0'..'9']) then
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
  JSONData: TJSONData;
begin
  Result := False;
  Erro   := '';
  Token  := Default(TTokenGtin);

  try
    JSONData := GetJSON(Resposta);
  except
    JSONData := nil;
  end;

  try
    Token.AccessToken  := JsonTexto(JSONData, 'access_token');
    if Token.AccessToken = '' then
      Token.AccessToken := JsonTexto(JSONData, 'token');
    Token.RefreshToken := JsonTexto(JSONData, 'refresh_token');
    Token.ExpiresIn    := StrToIntDef(JsonTexto(JSONData, 'expires_in'), 0);

    Result := Token.AccessToken <> '';
    if not Result then
      Erro := 'A API não retornou o token.';
  finally
    JSONData.Free;
  end;
end;

class function TControllerGtin.GetToken(const Username, Password: string;
  out Token: TTokenGtin; out Erro: string): Boolean;
var
  HTTPClient: TFPHTTPClient;
  Corpo     : TStringStream;
  Resposta  : TStringStream;
begin
  Result := False;
  Token  := Default(TTokenGtin);

  HTTPClient := CriarHTTP;
  // Corpo vazio: faz o cliente enviar Content-Length: 0 (sem ele o firewall responde 406)
  Corpo      := TStringStream.Create('');
  Resposta   := TStringStream.Create('');
  try
    // Codifica as credenciais (username:senha) em Base64 para o Basic Auth
    HTTPClient.AddHeader('Authorization', 'Basic ' + EncodeStringBase64(Username + ':' + Password));
    HTTPClient.RequestBody := Corpo;

    if Executar(HTTPClient, 'POST', ENDPOINT_OAUTH_TOKEN, Resposta, Erro) then
      Result := LerToken(Resposta.DataString, Token, Erro);
  finally
    HTTPClient.RequestBody := nil;
    HTTPClient.Free;
    Corpo.Free;
    Resposta.Free;
  end;
end;

class function TControllerGtin.RenovarToken(const RefreshToken: string;
  out Token: TTokenGtin; out Erro: string): Boolean;
var
  HTTPClient: TFPHTTPClient;
  JSONCorpo : TJSONObject;
  Corpo     : TStringStream;
  Resposta  : TStringStream;
begin
  // O refresh token só vale uma vez: guarde o novo par devolvido. Reutilizar um
  // refresh já consumido encerra a sessão e exige novo GetToken.
  Result := False;
  Token  := Default(TTokenGtin);

  JSONCorpo := TJSONObject.Create(['refresh_token', RefreshToken]);
  try
    Corpo := TStringStream.Create(JSONCorpo.AsJSON);
  finally
    JSONCorpo.Free;
  end;

  HTTPClient := CriarHTTP;
  Resposta   := TStringStream.Create('');
  try
    HTTPClient.AddHeader('Content-Type', 'application/json');
    HTTPClient.RequestBody := Corpo;

    if Executar(HTTPClient, 'POST', ENDPOINT_REFRESH_TOKEN, Resposta, Erro) then
      Result := LerToken(Resposta.DataString, Token, Erro);
  finally
    HTTPClient.RequestBody := nil;
    HTTPClient.Free;
    Corpo.Free;
    Resposta.Free;
  end;
end;

class function TControllerGtin.GetGTINInfo(const GTIN, AccessToken: string;
  out Infor, Erro: string): Boolean;
var
  HTTPClient: TFPHTTPClient;
  Resposta  : TStringStream;
  url       : string;
begin
  Infor := '';

  HTTPClient := CriarHTTP;
  Resposta   := TStringStream.Create('');
  try
    HTTPClient.AddHeader('Authorization', 'Bearer ' + AccessToken);
    url := StringReplace(GTIN_CONSULTAR, '{gtin}', GTIN, [rfReplaceAll]);

    Result := Executar(HTTPClient, 'GET', url, Resposta, Erro);
    if Result then
      Infor := Resposta.DataString;
  finally
    HTTPClient.Free;
    Resposta.Free;
  end;
end;

class function TControllerGtin.GetGTINImagem(const GTIN, AccessToken: string;
  Imagem: TStream; out Erro: string): Boolean;
var
  HTTPClient: TFPHTTPClient;
  url       : string;
begin
  // Produto sem foto retorna 200 com a imagem padrão "sem imagem".
  // O corpo pode ser PNG ou JPEG (TPicture.LoadFromStream identifica o formato).
  Imagem.Size := 0;

  HTTPClient := CriarHTTP;
  try
    HTTPClient.AddHeader('Authorization', 'Bearer ' + AccessToken);
    url := StringReplace(GTIN_IMAGEM, '{gtin}', GTIN, [rfReplaceAll]);

    Result := Executar(HTTPClient, 'GET', url, Imagem, Erro) and (Imagem.Size > 0);
    if Result then
      Imagem.Position := 0
    else
    begin
      if Erro = '' then
        Erro := 'A API não retornou a imagem.';
      Imagem.Size := 0;
    end;
  finally
    HTTPClient.Free;
  end;
end;

end.

