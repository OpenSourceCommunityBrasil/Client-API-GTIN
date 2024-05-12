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
  VERSAO_API  = '1.0.1';
  VERSAO_DEMO = '2.0';

  TITLE = 'CLIENT API GTIN by: OSCBR - Open Source Community Brasil';

  URL_BASE                 = 'https://gtin.rscsistemas.com.br';
  ENDPOINT_OAUTH_TOKEN     = URL_BASE  + '/oauth/token';
  ENDPOINT_INFOR           = URL_BASE  + '/api/gtin/infor';
  ENDPOINT_IMG             = URL_BASE  + '/api/gtin/img';

  INFOR_CONSULTAR          = ENDPOINT_INFOR  + '/{gtin}';
  INFOR_CADASTRAR          = ENDPOINT_INFOR;
  INFOR_ATUALIZAR          = ENDPOINT_INFOR;

  IMG_CONSULTAR            = ENDPOINT_IMG  + '/{gtin}';
  IMG_CADASTRAR            = ENDPOINT_IMG  + '/{gtin}';
  IMG_ATUALIZAR            = ENDPOINT_IMG  + '/{gtin}';

type

  TControllerGtin = class
    public
      class function GetToken(const Username, Password: string): string;
      class function GetGTINInfo(const GTIN, AccessToken: string): string;
      class function GetGTINImagem(const GTIN, AccessToken: string; out Imagem: TMemoryStream): Boolean;

  end;

implementation

{ TControllerGtin }

class function TControllerGtin.GetToken(const Username,
  Password: string): string;
var
  HTTPClient: TIdHTTP;
  AuthHeader: string;
  Stream    : TStringStream;
  Response: string;
  JSONData: TJSONObject;
begin

  Stream      :=  TStringStream.Create;
  HTTPClient  :=  TIdHTTP.Create(nil);
  try
    // Configuração do IOHandler SSL
    HTTPClient.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    TIdSSLIOHandlerSocketOpenSSL(HTTPClient.IOHandler).SSLOptions.Method := sslvTLSv1_2;
    TIdSSLIOHandlerSocketOpenSSL(HTTPClient.IOHandler).SSLOptions.Mode  :=  sslmClient;

    HTTPClient.ConnectTimeout:= 10000;
    HTTPClient.Request.Clear;
    HTTPClient.Request.BasicAuthentication:= False;

    // Codifica as credenciais para o formato Base64
    AuthHeader := 'Basic ' + TIdEncoderMIME.EncodeString(Username + ':' + Password);
    // Define o cabeçalho de autorização
    HTTPClient.Request.CustomHeaders.Add('Authorization:'+ AuthHeader);

    HTTPClient.Request.Accept :=  '*/*';
    HTTPClient.Request.AcceptEncoding :=  '';
    HTTPClient.Request.UserAgent  :=  'PostmanRuntime/7.38.0';

    // Faz a solicitação POST para obter o token
    try
      Response  :=  HTTPClient.Post(ENDPOINT_OAUTH_TOKEN, Stream);

      case HTTPClient.ResponseCode of
        200:
          begin
            // Recuperando o JSON
            JSONData := TJSONObject.ParseJSONValue(Response) as TJSONObject;
            try
              // Retornando apenas o token
              Result := JSONData.GetValue<string>('token');
            finally
              JSONData.Free;
            end;
          end
      else
        Result  :=  Response;
      end;

    Except
      On E: EIdHTTPProtocolException do
       Begin
        If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
         Begin
          If E.ErrorMessage <> '' Then
            begin
              Result  :=  E.ErrorMessage;
            end
          Else
            begin
              Result  :=  E.Message;
            end;
         End;
       End;
      on E: Exception do
        begin
          Result  :=  E.Message;
        end;
    end;
  finally
    Stream.Free;
    HTTPClient.IOHandler.Free;
    HTTPClient.Free;
  end;
end;

class function TControllerGtin.GetGTINInfo(const GTIN,
  AccessToken: string): string;
var
  sURL        : String ;
  Stream      : TStringStream ;
  vIdHTTP     : TIdHTTP;
begin

  sURL := StringReplace(INFOR_CONSULTAR, '{gtin}', GTIN, [rfReplaceAll]);

  Stream  := TStringStream.Create('', TEncoding.UTF8);
  vIdHTTP := TIdHTTP.Create(nil);
  try
    try
      vIdHTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      TIdSSLIOHandlerSocketOpenSSL(vIdHTTP.IOHandler).SSLOptions.Method := sslvTLSv1_2;
      TIdSSLIOHandlerSocketOpenSSL(vIdHTTP.IOHandler).SSLOptions.Mode  :=  sslmClient;

      vIdHTTP.ConnectTimeout:= 10000;
      vIdHTTP.Request.Clear;
      vIdHTTP.Request.BasicAuthentication:= False;
      vIdHTTP.Request.CustomHeaders.AddValue('Authorization','Bearer ' + AccessToken);

      Result :=  vIdHTTP.Get(sURL);

    Except
      On E: EIdHTTPProtocolException do
       Begin
        If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
         Begin
          If E.ErrorMessage <> '' Then
            begin
              Result  :=  E.ErrorMessage;
            end
          Else
            begin
              Result  :=  E.Message;
            end;
         End;
       End;
      on E: Exception do
        begin
          Result  :=  E.Message;
        end;
    end;
  finally
    vIdHTTP.IOHandler.Free;
    Stream.Free;
    vIdHTTP.Free;
  end;
end;

class function TControllerGtin.GetGTINImagem(const GTIN, AccessToken: string;
  out Imagem: TMemoryStream): Boolean;
var
  sURL        : String ;
  vIdHTTP     : TIdHTTP;
begin
  Result := False;

  sURL := StringReplace(IMG_CONSULTAR, '{gtin}', GTIN, [rfReplaceAll]);

  vIdHTTP := TIdHTTP.Create(nil);
  try
    try
      vIdHTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      TIdSSLIOHandlerSocketOpenSSL(vIdHTTP.IOHandler).SSLOptions.Method := sslvTLSv1_2;
      TIdSSLIOHandlerSocketOpenSSL(vIdHTTP.IOHandler).SSLOptions.Mode  :=  sslmClient;

      vIdHTTP.ConnectTimeout:= 10000;
      vIdHTTP.Request.Clear;
      vIdHTTP.Request.BasicAuthentication:= False;
      vIdHTTP.Request.CustomHeaders.AddValue('Authorization','Bearer ' + AccessToken);

      vIdHTTP.Get(sURL, Imagem);

      case vIdHTTP.ResponseCode of
        200:
          begin
             if (Imagem.Size <> 0) then
             begin
               Result := True;
               Imagem.Position := 0;
             end;
          end
      else

      end;

    Except
      On E: EIdHTTPProtocolException do
       Begin
        If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
         Begin
          If E.ErrorMessage <> '' Then
            begin
//              Result  :=  E.ErrorMessage;
            end
          Else
            begin
//              Result  :=  E.Message;
            end;
         End;
       End;
      on E: Exception do
        begin
//          Result  :=  E.Message;
        end;
    end;
  finally
    vIdHTTP.IOHandler.Free;
    vIdHTTP.Free;
  end;
end;

end.
