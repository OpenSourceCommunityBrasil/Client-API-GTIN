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
    Fean_tipo: string;
    FCest: string;
    Funid_abr: string;
    Flink_foto: string;
    FNcm: Integer;
    Fnome_acento: string;
    FNome: string;
    FEan: string;
    Funid_desc: string;
    Fdh_update: string;
    FCategoria: string;
    FMarca: string;
    FPais: string;


  public
    property Cest       : string  read FCest        write FCest;
    property Ean        : string  read FEan         write FEan;
    property ean_tipo   : string  read Fean_tipo    write Fean_tipo;
    property link_foto  : string  read Flink_foto   write Flink_foto;
    property Ncm        : Integer read FNcm         write FNcm;
    property Nome       : string  read FNome        write FNome;
    property nome_acento: string  read Fnome_acento write Fnome_acento;
    property unid_abr   : string  read Funid_abr    write Funid_abr;
    property unid_desc  : string  read Funid_desc   write Funid_desc;
    property Categoria  : string  read FCategoria   write FCategoria;
    property dh_update  : string  read Fdh_update   write Fdh_update;
    property Marca      : string  read FMarca       write FMarca;
    property Pais       : string  read FPais        write FPais;
  end;


implementation


end.
