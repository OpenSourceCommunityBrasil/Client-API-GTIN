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

unit uClientGtin.Classes;

interface

type

  TToken = class
  private
    Ftoken: string;
  public
    property token : string read Ftoken write Ftoken;

  end;


  TProduto = class
  private
    Fvalor_medio: double;
    FErro: integer;
    FAtualizado: integer;
    FValor: double;
    Fcest_codigo: string;
    Flink_foto: string;
    FCategoria: string;
    FNcm: integer;
    FAvg: double;
    FEmbalagem: string;
    FTributacao: string;
    Fproduto_acento: string;
    FMarca: string;
    FNome: string;
    FEan: string;
    Fdh_update: string;
    FPais: string;
    Fquantidade_embalagem: double;
    FEx: integer;

  public
    property Atualizado           : integer read FAtualizado           write FAtualizado;
    property Avg                  : double read FAvg                  write FAvg;
    property Categoria            : string read FCategoria            write FCategoria;
    property cest_codigo          : string read Fcest_codigo          write Fcest_codigo;
    property dh_update            : string read Fdh_update            write Fdh_update;
    property Ean                  : string read FEan                  write FEan;
    property Embalagem            : string read FEmbalagem            write FEmbalagem;
    property Erro                 : integer read FErro                 write FErro;
    property Ex                   : integer read FEx                   write FEx;
    property link_foto            : string read Flink_foto            write Flink_foto;
    property Marca                : string read FMarca                write FMarca;
    property Ncm                  : integer read FNcm                  write FNcm;
    property Nome                 : string read FNome                 write FNome;
    property Pais                 : string read FPais                 write FPais;
    property produto_acento       : string read Fproduto_acento       write Fproduto_acento;
    property quantidade_embalagem : double read Fquantidade_embalagem write Fquantidade_embalagem;
    property Tributacao           : string read FTributacao           write FTributacao;
    property Valor                : double read FValor                write FValor;
    property valor_medio          : double read Fvalor_medio          write Fvalor_medio;
  end;


implementation


end.
