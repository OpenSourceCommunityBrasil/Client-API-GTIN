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
  Vcl.Buttons, dxGDIPlusClasses, vcl.Imaging.pngimage, vcl.Imaging.jpeg, Winapi.ShellAPI

  , uClientGtin.Classes
  , uClientGtin.Consts

  , IdHTTP

  , REST.Json


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
    Label8: TLabel;
    edt_valor: TEdit;
    Label13: TLabel;
    edt_link_foto: TEdit;
    Label9: TLabel;
    edt_pais: TEdit;
    Label10: TLabel;
    edt_marca: TEdit;
    Label11: TLabel;
    edt_ex: TEdit;
    Label12: TLabel;
    edt_avg: TEdit;
    Label14: TLabel;
    edt_categoria: TEdit;
    Label15: TLabel;
    edt_valor_medio: TEdit;
    Label16: TLabel;
    edt_atualizado: TEdit;
    Label18: TLabel;
    edt_embalagem: TEdit;
    Label17: TLabel;
    edt_cest_codigo: TEdit;
    Label19: TLabel;
    edt_dh_update: TEdit;
    Label20: TLabel;
    edt_erro: TEdit;
    Label21: TLabel;
    edt_quantidade_embalagem: TEdit;
    Label22: TLabel;
    edt_tributacao: TEdit;
    Label23: TLabel;
    edt_produto_acento: TEdit;
    img_produto: TImage;
    Image1: TImage;
    Image2: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtn_pesquisar_eanClick(Sender: TObject);
    procedure edt_usuarioChange(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
  private
    Ftoken: TToken;
    FProduto : TProduto;
    { Private declarations }
    procedure LimparCampos;

    function obterToken: Boolean;

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



procedure TFrmGtin.edt_usuarioChange(Sender: TObject);
begin
  if Trim(TEdit(Sender).Text) <> '' then
    TEdit(Sender).Tag :=  1
  else
    TEdit(Sender).Tag := 0;
end;

procedure TFrmGtin.FormCreate(Sender: TObject);
begin
  LimparCampos;
end;

procedure TFrmGtin.FormDestroy(Sender: TObject);
begin
  if Ftoken <> nil then
    Ftoken.Free;

  if FProduto <> nil then
    FProduto.Free;
end;

procedure TFrmGtin.FormShow(Sender: TObject);
begin
  sELF.Caption      :=  TITLE;
  lblTitle.Caption  := Self.Caption;
  lblversao.Caption :=  'Versão API: ' + VERSAO_API  + ' - Versão Cliente: '  + VERSÃO_DEMO ;

  edt_pesquisa_ean.Text :=  '7891222216644';

  edt_usuario.Text  :=  'Usuário';
  edt_senha.Text    :=  'Senha';
end;

procedure TFrmGtin.GetFotoProduto;
var
  sURL    : String ;
  Strm    : TMemoryStream;
  vIdHTTP : TIdHTTP;
begin
  if (not obterToken) then
    Exit;

  Screen.Cursor := crHourGlass;
  Strm := TMemoryStream.Create;
  vIdHTTP := TIdHTTP.Create(nil);
  try
    sURL := ENDPOINT_IMG;
    sURL := StringReplace(sURL, '{id}', edt_pesquisa_ean.Text, [rfReplaceAll]);

    try
      vIdHTTP.Request.BasicAuthentication :=  False;
      vIdHTTP.Request.CustomHeaders.Clear;
      vIdHTTP.Request.CustomHeaders.AddValue('Authorization','Bearer ' + Ftoken.token);
      vIdHTTP.Get(sURL, Strm);
      if (Strm.Size <> 0) then
      begin
        Strm.Position := 0;
        img_produto.Picture.LoadFromStream(Strm);
      end;
    except on E: Exception do
      begin
        MessageDlg(e.message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      end;
    end;
  finally
    Strm.Free;
    vIdHTTP.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmGtin.GetInforEan;
var
  sURL        : String ;
  retorno     : string;
  nResp       : Integer ;
  Stream      : TStringStream ;
  vIdHTTP     : TIdHTTP;

begin
  if (not obterToken) then
    Exit;

  sURL := ENDPOINT_INFOR;

  Screen.Cursor := crHourGlass;
  Stream  := TStringStream.Create('', TEncoding.UTF8);
  vIdHTTP := TIdHTTP.Create(nil);
  try
    try
      sURL := StringReplace(sURL, '{id}', edt_pesquisa_ean.Text, [rfReplaceAll]);

      vIdHTTP.Request.BasicAuthentication :=  False;
      vIdHTTP.Request.CustomHeaders.Clear;
      vIdHTTP.Request.CustomHeaders.AddValue('Authorization','Bearer ' + Ftoken.token);
      vIdHTTP.Get(sURL, Stream);

      case vIdHTTP.ResponseCode  of
        200:
          begin
            if (Stream.Size <> 0) then
              begin
                Stream.Position := 0;
                Retorno     := UTF8ToWideString(RawByteString(Stream.DataString));

                if FProduto <> nil then
                  FProduto.Free;

                FProduto  := TJson.JsonToObject<TProduto>(Retorno);
              end;

            if FProduto <> nil then
              begin
                edt_ean.Text                    :=  FProduto.ean;
                edt_nome.Text                   :=  FProduto.nome;
                edt_ncm.Text                    :=  FProduto.ncm.ToString;
                edt_valor.Text                  :=  FProduto.valor.ToString;
                edt_avg.Text                    :=  FProduto.avg.ToString;
                edt_ex.Text                     :=  FProduto.ex.ToString;
                edt_marca.Text                  :=  FProduto.marca;
                edt_pais.Text                   :=  FProduto.pais;
                edt_categoria.Text              :=  FProduto.categoria;
                edt_valor_medio.Text            :=  FProduto.valor_medio.ToString;
                edt_atualizado.Text             :=  FProduto.atualizado.ToString;
                edt_link_foto.Text              :=  FProduto.link_foto;
                edt_cest_codigo.Text            :=  FProduto.cest_codigo;
                edt_dh_update.Text              :=  FProduto.dh_update;
                edt_erro.Text                   :=  FProduto.erro.ToString;
                edt_embalagem.Text              :=  FProduto.embalagem;
                edt_quantidade_embalagem.Text   :=  FProduto.quantidade_embalagem.ToString;
                edt_tributacao.Text             :=  FProduto.tributacao;
                edt_produto_acento.Text         :=  FProduto.produto_acento;
              end;
          end;
      else
        if FProduto <> nil then
          FProduto.Free;
      end;
    except on E: Exception do
      begin
        if FProduto <> nil then
          FProduto.Free;
        MessageDlg(e.message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      end;
    end;
  finally
    Stream.Free;
    vIdHTTP.Free;
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
               'https://oscbr.com.br/gtinmain',
               nil,
               nil,
               SW_SHOWMAXIMIZED);
end;

function TFrmGtin.obterToken: Boolean;
var
  Strm: TStringStream;
  vIdHTTP : TIdHTTP;
  retorno : string;
  raw : TStringList;
begin
  Result :=  True;
  Screen.Cursor := crHourGlass;
  Strm := TStringStream.Create('', TEncoding.UTF8);
  vIdHTTP := TIdHTTP.Create(nil);
  raw := TStringList.Create;
  try
    try
      vIdHTTP.Request.CustomHeaders.Clear;
      vIdHTTP.Request.CustomHeaders.AddValue('username', Trim(edt_usuario.Text));
      vIdHTTP.Request.CustomHeaders.AddValue('password', Trim(edt_senha.Text));
      vIdHTTP.Request.BasicAuthentication :=  False;
      retorno  :=  vIdHTTP.Post(ENDPOINT_GETTOKEN, Strm);
      raw.Text  :=  vIdHTTP.Response.RawHeaders.Text;
      case vIdHTTP.ResponseCode  of
        200:
          begin
            if Ftoken <> nil then
              Ftoken.Free;
            Ftoken  := TJson.JsonToObject<TToken>(Retorno);
          end;
      else
        if Ftoken <> nil then
          Ftoken.Free;
        Result :=  False;
        MessageDlg(UTF8ToWideString(RawByteString(Strm.DataString)), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      end;
    except on E: Exception do
      begin
        raw.Text  :=  vIdHTTP.Response.RawHeaders.Text;
        if Ftoken <> nil then
          Ftoken.Free;
        Result :=  False;
        MessageDlg(e.Message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      end;
    end;
  finally
    Strm.Free;
    vIdHTTP.Free;
    Screen.Cursor := crDefault;
    raw.Free;
  end;
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
