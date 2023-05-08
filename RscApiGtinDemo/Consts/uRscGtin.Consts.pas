{####################################################################################################################
                              OSCBR -> Open Source Community Brasil  -  https://oscbr.com.br
####################################################################################################################
                                                  API GTIN
####################################################################################################################
    Owner.....: Roniery Santos Cardoso / OSCBR
    Github....: https://github.com/OpenSourceCommunityBrasil/demo-API-GTIN
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

unit uRscGtin.Consts;

interface


const

  VERSAO_API  = '1.0';
  VERSÃO_DEMO = '1.0';

  TITLE = 'API GTIN by: OSCBR - Open Source Community Brasil';

  ENDPOINT_GETTOKEN = 'https://oscbr.com.br:9092/gettoken';

  ENDPOINT_INFOR    = 'https://oscbr.com.br:9092/api/gtin/infor?gtin={id}';
  ENDPOINT_IMG      = 'https://oscbr.com.br:9092/api/gtin/img?gtin={id}';


implementation

end.
