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
  , base64, Dialogs;

const
  VERSAO_API  = '1.0.1';
  VERSAO_DEMO = '2.0';

  TITLE = 'CLIENT API GTIN by: OSCBR - Open Source Community Brasil';

  URL_BASE                 = 'https://gtin.rscsistemas.com.br';
  ENDPOINT_OAUTH_TOKEN     = '/oauth/token';
  ENDPOINT_INFOR           = URL_BASE  + '/api/gtin/infor';
  ENDPOINT_IMG             = URL_BASE  + '/api/gtin/img';

  INFOR_CONSULTAR          = ENDPOINT_INFOR  + '/{gtin}';
  INFOR_CADASTRAR          = ENDPOINT_INFOR;
  INFOR_ATUALIZAR          = ENDPOINT_INFOR;

  IMG_CONSULTAR            = ENDPOINT_IMG  + '/{gtin}';
  IMG_CADASTRAR            = ENDPOINT_IMG  + '/{gtin}';
  IMG_ATUALIZAR            = ENDPOINT_IMG  + '/{gtin}';



type
    { TControllerGtin }

    TControllerGtin = class
    private
    public
      class function GetToken(const Username, Password: string): string;
      class function GetGTINInfo(const GTIN, AccessToken: string): string;
      class function GetGTINImagem(const GTIN, AccessToken: string; out Imagem: TMemoryStream): Boolean;
    end;

implementation

{ TControllerGtin }

class function TControllerGtin.GetToken(const Username, Password: string
  ): string;
var
  HTTPClient: TFPHTTPClient;
  AuthHeader: string;
  RequestBody: TStringList;
  Response: string;
  JSONData: TJSONData;
begin
  HTTPClient := TFPHTTPClient.Create(nil);
  RequestBody := TStringList.Create;
  try
    // Codifica as credenciais para o formato Base64
    AuthHeader := 'Basic ' + EncodeStringBase64(Username+':'+Password);
    // Define os cabeçalhos da solicitação
    HTTPClient.AddHeader('Authorization', AuthHeader);
    // Faz a solicitação POST para obter o token
    Response := HTTPClient.FormPost(URL_BASE + ENDPOINT_OAUTH_TOKEN, RequestBody);
    // recuperando o json
    JSONData := GetJSON(Response);
    // retornando apenas o token
    Result := JSONData.FindPath('token').AsString;
  finally
    HTTPClient.Free;
    RequestBody.Free;
  end;
end;

class function TControllerGtin.GetGTINInfo(const GTIN, AccessToken: string
  ): string;
var
  HTTPClient: TFPHTTPClient;
  url: string;
begin
  HTTPClient := TFPHTTPClient.Create(nil);
  try
     try
       HTTPClient.AddHeader('Authorization', 'Bearer ' + AccessToken);
       url := StringReplace(INFOR_CONSULTAR, '{gtin}', GTIN, [rfReplaceAll]);
       Result := HTTPClient.Get(url);
     except on E: Exception do
     begin
          Result := e.Message;
     end;
     end;
  finally
    HTTPClient.Free;
  end;
end;

class function TControllerGtin.GetGTINImagem(const GTIN, AccessToken: string;
  out Imagem: TMemoryStream): Boolean;
var
  HTTPClient: TFPHTTPClient;
  url: string;
begin
  Result := False;

  if not Assigned(Imagem) then
     Imagem := TMemoryStream.Create;

  HTTPClient := TFPHTTPClient.Create(nil);
  try
     try
       HTTPClient.AddHeader('Authorization', 'Bearer ' + AccessToken);
       url := StringReplace(IMG_CONSULTAR, '{gtin}', GTIN, [rfReplaceAll]);
       HTTPClient.Get(url, Imagem);
       if (Imagem.Size <> 0) then
       begin
         Result := True;
         Imagem.Position := 0;
       end;
     except
       on E: Exception do
       begin
         MessageDlg(E.Message, mtError, [mbOK], 0);
       end;
     end;
  finally
    HTTPClient.Free;
  end;

end;

end.


