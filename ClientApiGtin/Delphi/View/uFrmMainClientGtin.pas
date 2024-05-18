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

unit uFrmMainClientGtin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, vcl.Imaging.pngimage, vcl.Imaging.jpeg, Winapi.ShellAPI

  , Controller.Gtin 

  , REST.Json
  , System.JSON


  ;



type
  TFrmGtin = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edt_usuario: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edt_senha: TEdit;
    Panel2: TPanel;
    lblTitle: TLabel;
    lblversao: TLabel;
    Panel3: TPanel;
    Label4: TLabel;
    edt_pesquisa_ean: TEdit;
    sbtn_pesquisar_ean: TSpeedButton;
    rdgTipoConsulta: TRadioGroup;
    Label5: TLabel;
    edt_ean: TEdit;
    Label6: TLabel;
    edt_nome: TEdit;
    Label7: TLabel;
    edt_ncm: TEdit;
    Label13: TLabel;
    edt_link_foto: TEdit;
    Label9: TLabel;
    edt_pais: TEdit;
    Label10: TLabel;
    edt_marca: TEdit;
    Label14: TLabel;
    edt_categoria: TEdit;
    Label17: TLabel;
    edt_cest_codigo: TEdit;
    Label19: TLabel;
    edt_dh_update: TEdit;
    Label23: TLabel;
    edt_produto_acento: TEdit;
    img_produto: TImage;
    Image1: TImage;
    Image2: TImage;
    mm_Token: TMemo;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtn_pesquisar_eanClick(Sender: TObject);
    procedure edt_usuarioChange(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FImgDefault : TImage;
    { Private declarations }
    procedure LimparCampos;

    procedure GetInforEan;
    procedure GetFotoProduto;

  public
    { Public declarations }
  end;    

var
  FrmGtin: TFrmGtin;

implementation



{$R *.dfm}

{ TForm2 }



procedure TFrmGtin.Button1Click(Sender: TObject);
var
  stoken: string;
begin
  if TControllerGtin.GetToken(Trim(edt_usuario.Text), Trim(edt_senha.Text), stoken) then
    mm_Token.Text :=  stoken;
end;

procedure TFrmGtin.edt_usuarioChange(Sender: TObject);
begin
  if Trim(TEdit(Sender).Text) <> '' then
    TEdit(Sender).Tag :=  1
  else
    TEdit(Sender).Tag := 0;
end;

procedure TFrmGtin.FormCreate(Sender: TObject);
begin
  FImgDefault := TImage.Create(nil);
  FImgDefault.Picture :=  img_produto.Picture;

  LimparCampos;
end;

procedure TFrmGtin.FormDestroy(Sender: TObject);
begin
  FImgDefault.Free;
end;

procedure TFrmGtin.FormShow(Sender: TObject);
begin
  sELF.Caption      :=  TITLE;
  lblTitle.Caption  := Self.Caption;
  lblversao.Caption :=  'Versão API: ' + VERSAO_API  + ' - Versão Cliente: '  + VERSAO_DEMO ;

  edt_pesquisa_ean.Text :=  '7891222216644';

  edt_usuario.Text  :=  'Usuário';
  edt_senha.Text    :=  'Senha';
end;

procedure TFrmGtin.GetFotoProduto;
var
  Strm    : TMemoryStream;
begin
  if (mm_Token.Text = '') then
    Exit;

  Screen.Cursor := crHourGlass;
  Strm  :=  TMemoryStream.Create;
  try
    if TControllerGtin.GetGTINImagem(Trim(edt_pesquisa_ean.Text), Trim(mm_Token.Text), Strm) then
      begin
        img_produto.Picture.LoadFromStream(Strm);
      end;
  finally
    Strm.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmGtin.GetInforEan;
var
  retorno     : string;
  ProdJson: TJSONObject;
begin
  if (mm_Token.Text = '') then
    Exit;
  Screen.Cursor := crHourGlass;
  try
    if not TControllerGtin.GetGTINInfo(Trim(edt_pesquisa_ean.Text), Trim(mm_Token.Text), retorno) then
      Exit;

    ProdJson  :=  TJSONObject.ParseJSONValue(retorno) as TJSONObject;
    try
      edt_ean.Text                    :=  ProdJson.GetValue<string>('ean');
      edt_nome.Text                   :=  ProdJson.GetValue<string>('nome');
      edt_ncm.Text                    :=  ProdJson.GetValue<string>('ncm');
      edt_marca.Text                  :=  ProdJson.GetValue<string>('marca');
      edt_pais.Text                   :=  ProdJson.GetValue<string>('pais');
      edt_categoria.Text              :=  ProdJson.GetValue<string>('categoria');
      edt_link_foto.Text              :=  ProdJson.GetValue<string>('link_foto');
      edt_cest_codigo.Text            :=  ProdJson.GetValue<string>('cest');
      edt_dh_update.Text              :=  ProdJson.GetValue<string>('dh_update');
      edt_produto_acento.Text         :=  ProdJson.GetValue<string>('nome_acento');
    finally
      ProdJson.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmGtin.Image1Click(Sender: TObject);
begin
  ShellExecute(Handle,
               'open',
               'https://github.com/OpenSourceCommunityBrasil/Client-API-GTIN',
               nil,
               nil,
               SW_SHOWMAXIMIZED);
end;

procedure TFrmGtin.Image2Click(Sender: TObject);
begin
  ShellExecute(Handle,
               'open',
               'https://gtin.rscsistemas.com.br',
               nil,
               nil,
               SW_SHOWMAXIMIZED);
end;

procedure TFrmGtin.sbtn_pesquisar_eanClick(Sender: TObject);
begin
  LimparCampos;

  case rdgTipoConsulta.ItemIndex of
    0:
      begin
        GetInforEan;
      end;
    1:
      begin
        GetFotoProduto;
      end;
    2:
      begin
        GetInforEan;
        GetFotoProduto;
      end;
  end;
end;

procedure TFrmGtin.LimparCampos;
var
  C: Integer;
begin
  img_produto.Picture :=  FImgDefault.Picture;
  for C := 0 to Self.ComponentCount - 1 do
  begin
    if Self.Components[C] is TEdit then
    begin
      if TEdit(Self.Components[C]).Tag = 0 then
        TEdit(Self.Components[C]).Clear;
    end;
  end;
end;


end.
