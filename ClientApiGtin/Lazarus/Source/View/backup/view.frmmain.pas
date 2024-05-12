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
    edt_dh_update: TEdit;
    edt_ean: TEdit;
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
    Label13: TLabel;
    Label14: TLabel;
    Label17: TLabel;
    Label19: TLabel;
    Label2: TLabel;
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
    procedure BuscarInformacao;
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
begin
  mm_Token.Text:=TControllerGtin.GetToken(Trim(Edt_Usuario.Text), Trim(Edt_Senha.Text));
end;

procedure TForm1.Btn_ConsultarClick(Sender: TObject);
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
    BuscarInformacao;
    BuscarFoto;
  end;



end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.Caption      := TITLE;
  lblTitle.Caption  := Self.Caption;
  lblversao.Caption := 'Versão API: ' + VERSAO_API  + ' - Versão Cliente: '  + VERSAO_DEMO ;
  Edt_Gtin.Text     := '7896116900029';
  mm_Token.Text     := 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOjIwOCwiZXhwIjoxNzE1NDgxOTk1LCJpYXQiOjE3MTU0NzgzOTV9.ZU-CD7g4l2dXwN7bBCdLmOsc8pzb4jWFKilkj7SFVdc';
end;

procedure TForm1.img_UrlGitHubClick(Sender: TObject);
begin
  OpenURL('https://github.com/OpenSourceCommunityBrasil/Client-API-GTIN');
end;

procedure TForm1.img_UrlGtinClick(Sender: TObject);
begin
  OpenURL('https://gtin.rscsistemas.com.br');
end;

procedure TForm1.BuscarInformacao;
var
  JSONData: TJSONData;
  Response: string;
begin
  Response := TControllerGtin.GetGTINInfo(Trim(Edt_Gtin.Text), Trim(mm_Token.Text));
  JSONData := GetJSON(Response);

  edt_ean.Text := JSONData.FindPath('ean').AsString;
  //edt_categoria.Text := JSONData.FindPath('ean_tipo').AsString;
  edt_cest_codigo.Text := JSONData.FindPath('cest').AsString;
  edt_ncm.Text := JSONData.FindPath('ncm').AsString;
  edt_nome.Text := JSONData.FindPath('nome').AsString;
  edt_produto_acento.Text := JSONData.FindPath('nome_acento').AsString;
  //edt_categoria.Text := JSONData.FindPath('unid_abr').AsString;
  //edt_categoria.Text := JSONData.FindPath('unid_desc').AsString;
  edt_marca.Text := JSONData.FindPath('marca').AsString;
  edt_pais.Text := JSONData.FindPath('pais').AsString;
  edt_categoria.Text := JSONData.FindPath('categoria').AsString;
  edt_dh_update.Text := JSONData.FindPath('dh_update').AsString;
  edt_link_foto.Text := JSONData.FindPath('link_foto').AsString;
end;

procedure TForm1.BuscarFoto;
var
  vImagem: TMemoryStream;
begin
  vImagem := TMemoryStream.Create;
  try
    TControllerGtin.GetGTINImagem(Trim(Edt_Gtin.Text), Trim(mm_Token.Text), vImagem);
    if (vImagem.Size <> 0) then
    begin
      vImagem.Position := 0;
      img_produto.Picture.LoadFromStream(vImagem);
    end;
  finally
    vImagem.Free;
  end;
end;

end.

