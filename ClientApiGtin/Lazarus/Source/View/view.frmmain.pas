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

unit View.FrmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls
  , LCLIntf, fpjson, jsonparser;

type

  { TForm1 }

  TForm1 = class(TForm)
    Btn_SolicitarToken: TButton;
    Btn_Consultar: TButton;
    edt_categoria: TEdit;
    edt_cest_codigo: TEdit;
    edt_ean_tipo: TEdit;
    edt_unid_desc: TEdit;
    edt_dh_update: TEdit;
    edt_ean: TEdit;
    edt_unid_abr: TEdit;
    edt_link_foto: TEdit;
    edt_marca: TEdit;
    edt_ncm: TEdit;
    edt_nome: TEdit;
    edt_pais: TEdit;
    edt_produto_acento: TEdit;
    Edt_Senha: TEdit;
    Edt_Usuario: TEdit;
    Edt_Gtin: TEdit;
    img_produto: TImage;
    img_UrlGitHub: TImage;
    img_UrlGtin: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label23: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblTitle: TLabel;
    lblversao: TLabel;
    mm_Token: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    rdgTipoConsulta: TRadioGroup;
    procedure Btn_ConsultarClick(Sender: TObject);
    procedure Btn_SolicitarTokenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure img_UrlGitHubClick(Sender: TObject);
    procedure img_UrlGtinClick(Sender: TObject);
  private
    function BuscarInformacao: Boolean;
    procedure BuscarFoto;

  public

  end;

var
  Form1: TForm1;

implementation

uses
    Controller.Gtin;

{$R *.lfm}

{ TForm1 }

procedure TForm1.Btn_SolicitarTokenClick(Sender: TObject);
var
  Token: TTokenGtin;
  Erro : string;
begin
  mm_Token.Clear;
  if TControllerGtin.GetToken(Trim(Edt_Usuario.Text), Trim(Edt_Senha.Text), Token, Erro) then
    mm_Token.Text := Token.AccessToken
  else
    MessageDlg('Falha ao obter o token.' + LineEnding + Erro, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
end;

procedure TForm1.Btn_ConsultarClick(Sender: TObject);
var
  Erro: string;
begin
  if Trim(mm_Token.Text) = '' then
   begin
     MessageDlg('Token não Localizado', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
     Exit;
   end;

  if Trim(Edt_Gtin.Text) = '' then
   begin
     MessageDlg('GTIN não Informado!', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
     Exit;
   end;

  // Valida antes de consultar: GTIN inválido repetido suspende as consultas (429)
  if not TControllerGtin.ValidarGTIN(Trim(Edt_Gtin.Text), Erro) then
   begin
     MessageDlg(Erro, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
     Exit;
   end;

  case rdgTipoConsulta.ItemIndex of
  0:
    begin
      BuscarInformacao;
    end;
  1:
    begin
      BuscarFoto;
    end;
  else
    if BuscarInformacao then
      BuscarFoto;
  end;



end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.Caption      := TITLE;
  lblTitle.Caption  := Self.Caption;
  lblversao.Caption := 'Versão API: ' + VERSAO_API  + ' - Versão Cliente: '  + VERSAO_DEMO ;
  Edt_Gtin.Text     := '7896116900029';
  mm_Token.Clear;
end;

procedure TForm1.img_UrlGitHubClick(Sender: TObject);
begin
  OpenURL('https://github.com/OpenSourceCommunityBrasil/Client-API-GTIN');
end;

procedure TForm1.img_UrlGtinClick(Sender: TObject);
begin
  OpenURL('https://gtin.rscsistemas.com.br');
end;

function TForm1.BuscarInformacao: Boolean;
var
  JSONData: TJSONData;
  Response: string;
  Erro    : string;
begin
  Result := TControllerGtin.GetGTINInfo(Trim(Edt_Gtin.Text), Trim(mm_Token.Text), Response, Erro);
  if not Result then
  begin
    MessageDlg('Falha ao consultar o produto.' + LineEnding + Erro, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  JSONData := GetJSON(Response);
  try
    edt_ean.Text := TControllerGtin.JsonTexto(JSONData, 'ean');
    edt_ean_tipo.Text := TControllerGtin.JsonTexto(JSONData, 'ean_tipo');
    edt_cest_codigo.Text := TControllerGtin.JsonTexto(JSONData, 'cest');
    edt_ncm.Text := TControllerGtin.JsonTexto(JSONData, 'ncm');
    edt_nome.Text := TControllerGtin.JsonTexto(JSONData, 'nome');
    edt_produto_acento.Text := TControllerGtin.JsonTexto(JSONData, 'nome_acento');
    edt_unid_abr.Text := TControllerGtin.JsonTexto(JSONData, 'unid_abr');
    edt_unid_desc.Text := TControllerGtin.JsonTexto(JSONData, 'unid_desc');
    edt_marca.Text := TControllerGtin.JsonTexto(JSONData, 'marca');
    edt_pais.Text := TControllerGtin.JsonTexto(JSONData, 'pais');
    edt_categoria.Text := TControllerGtin.JsonTexto(JSONData, 'categoria');
    edt_dh_update.Text := TControllerGtin.JsonTexto(JSONData, 'dh_update');
    edt_link_foto.Text := TControllerGtin.JsonTexto(JSONData, 'link_foto');
  finally
    JSONData.Free;
  end;
end;

procedure TForm1.BuscarFoto;
var
  vImagem: TMemoryStream;
  Erro   : string;
begin
  vImagem := TMemoryStream.Create;
  try
    if TControllerGtin.GetGTINImagem(Trim(Edt_Gtin.Text), Trim(mm_Token.Text), vImagem, Erro) then
      img_produto.Picture.LoadFromStream(vImagem)
    else
      MessageDlg('Falha ao buscar a imagem.' + LineEnding + Erro, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
  finally
    vImagem.Free;
  end;
end;

end.

