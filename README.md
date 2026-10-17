# 📃 Client API GTIN

### OSCBR - Open Source Community Brasil
🌐 **Site:** [https://gtin.rscsistemas.com.br](https://gtin.rscsistemas.com.br) · 📚 **Documentação oficial:** [/documentacao](https://gtin.rscsistemas.com.br/documentacao)

Cliente de exemplo (Delphi e Lazarus) e guia de integração da **API GTIN**: consulta de produtos por código de barras GTIN/EAN (nome, marca, NCM/CEST, imagem).

---

## ⚠️ Migração obrigatória: as rotas antigas foram removidas

As rotas sem versão foram **desativadas em 10/09/2026 e removidas em 11/09/2026**. Hoje elas respondem `404 Rota nao encontrada` e não retornam produtos.

| Rota antiga (removida) | Rota atual |
|---|---|
| `POST /oauth/token` | `POST /api/v3/oauth/token` (ou `/api/v4/oauth/token`) |
| `GET /api/gtin/infor/{gtin}` | `GET /api/v3/gtin/{gtin}` (ou `/api/v4/gtin/{gtin}`) |
| `GET /api/gtin/img/{gtin}` | `GET /api/v3/gtin/{gtin}/image` (ou `/api/v4/gtin/{gtin}/image?size=500`) |

**Prazo de 20/10/2026:** a partir dessa data, enquanto a sua credencial continuar chamando as rotas antigas, as suas consultas na V3/V4 ficam limitadas a 10% do req/dia e do req/minuto do plano (resposta `403` com motivo `limite_rota_antiga`). O limite normal volta sozinho 24 h depois da última chamada antiga. A área do cliente mostra de quais IPs vieram essas chamadas.

> Este cliente já usa a **API V3** desde a versão 3.0. Se você copiou o código de uma versão anterior, atualize as URLs e veja a seção [Erro 406](#-erro-406-not-acceptable-firewall-da-hospedagem): o User-Agent padrão do Indy é recusado no POST do token.

---

## 📋 Cadastro

Para usar a API é preciso ter usuário e senha. Cadastre-se em
🔗 [https://gtin.rscsistemas.com.br/cadastro](https://gtin.rscsistemas.com.br/cadastro)

O cadastro e o uso da API seguem os [Termos de Uso](https://gtin.rscsistemas.com.br/termos-de-uso) e a [Política de Privacidade](https://gtin.rscsistemas.com.br/politica-de-privacidade). As versões vigentes vêm no cabeçalho `X-Termos-Versao` de toda resposta da API.

---

## 🧩 V3 ou V4?

As duas versões coexistem e usam o **mesmo token**. O que define a versão é o prefixo da URL.

| | V3 | V4 |
|---|---|---|
| Schema | simples e plano (nome, marca, NCM/CEST, link da foto) | rico e aninhado (fabricante, conteúdo/embalagem, classificação fiscal, imagens em 3 tamanhos, qualidade dos dados) |
| Indicada para | quem só precisa dos campos básicos | integrações novas |
| Descontinuação | sem data prevista | — |

Cada plano libera a consulta pela V3, pela V4 ou pelas duas. Pedir o token em `/api/v4/oauth/token` sem a V4 no plano responde `403`; nesse caso use `/api/v3/oauth/token`.

---

## 💻 O cliente deste repositório

| Projeto | Caminho | Requisitos |
|---|---|---|
| Delphi (VCL + Indy) | [ClientApiGtin/Delphi/Projeto/ClientAPIGtin.dproj](ClientApiGtin/Delphi/Projeto/ClientAPIGtin.dproj) | Delphi 10.2 ou superior (testado no 10.2 e no 12). DLLs do OpenSSL 1.0.2 (`libeay32.dll` e `ssleay32.dll`) ao lado do executável ou no PATH, na mesma arquitetura (32/64 bits) do executável |
| Lazarus (LCL + fphttpclient) | [ClientApiGtin/Lazarus/Projeto/ClientGtin.lpi](ClientApiGtin/Lazarus/Projeto/ClientGtin.lpi) | Lazarus com FPC 3.2 ou superior (testado no FPC 3.2.2). DLLs do OpenSSL 1.1 |

Toda a comunicação com a API fica na unit `Controller.Gtin` ([Delphi](ClientApiGtin/Delphi/Controller/Controller.Gtin.pas) · [Lazarus](ClientApiGtin/Lazarus/Source/Controller/controller.gtin.pas)), que você pode copiar para o seu sistema:

| Método | O que faz |
|---|---|
| `GetToken(Usuario, Senha, out Token, out Erro)` | Emite o token (`POST /api/v3/oauth/token`). `Token` traz `AccessToken`, `RefreshToken` e `ExpiresIn` |
| `RenovarToken(RefreshToken, out Token, out Erro)` | Renova a sessão (`POST /api/auth/refresh`) e devolve o novo par de tokens |
| `GetGTINInfo(GTIN, AccessToken, out Infor, out Erro)` | Consulta o produto e devolve o JSON (`GET /api/v3/gtin/{gtin}`) |
| `GetGTINImagem(GTIN, AccessToken, Imagem, out Erro)` | Baixa a imagem para um `TStream` (`GET /api/v3/gtin/{gtin}/image`) |
| `ValidarGTIN(GTIN, out Erro)` | Valida formato e dígito verificador **antes** de consultar |
| `JsonTexto(Obj, Nome)` | Lê um campo do JSON; ausente ou `null` vira texto vazio |

Todos retornam `Boolean`. Em caso de falha, `Erro` traz o status HTTP e a mensagem da API (`mensagem`/`erro` e, quando houver, o link `ajuda`).

Para usar a V4, troque `VERSAO_API` para `'v4'` na unit. A resposta da V4 tem outro formato (veja [Consultar produto V4](#consultar-produto-v4)), então a leitura dos campos no formulário precisa ser ajustada.

---

## 🔐 Autenticação

### Gerar token

- **URL:** `POST https://gtin.rscsistemas.com.br/api/v3/oauth/token` (ou `/api/v4/oauth/token`)
- **Headers:**
  - `Authorization: Basic base64(usuario:senha)`
  - `Accept: application/json`
  - `Content-Length: 0`: o POST não tem corpo, mas o cabeçalho é obrigatório (sem ele o firewall responde 406)
  - `User-Agent: NomeDoSeuSistema/1.0`: veja [Erro 406](#-erro-406-not-acceptable-firewall-da-hospedagem)

**Resposta 200**
```json
{
  "token": "ACCESS_TOKEN",
  "access_token": "ACCESS_TOKEN",
  "token_type": "Bearer",
  "expires_in": 3600,
  "expires_at": "2026-10-17T15:00:00Z",
  "refresh_token": "REFRESH_TOKEN",
  "refresh_expires_in": 604800,
  "refresh_expires_at": "2026-10-24T14:00:00Z"
}
```

- O access token vale **1 hora** (`expires_in`) e é enviado nas demais chamadas em `Authorization: Bearer ACCESS_TOKEN`.
- O refresh token vale **7 dias** e serve para renovar a sessão sem enviar a senha de novo.
- `token` e `access_token` têm o mesmo valor (`token` é mantido por compatibilidade).
- Login com bloqueio por tentativas: 5 falhas por usuário ou 20 por IP em 15 minutos.

### Renovar token

- **URL:** `POST https://gtin.rscsistemas.com.br/api/auth/refresh` (aliases: `/api/v3/refresh` e `/api/v4/refresh`)
- **Corpo:** `{"refresh_token": "SEU_REFRESH_TOKEN"}` com `Content-Type: application/json`
- Não precisa de access token válido.

A resposta tem o mesmo formato da emissão, com um **novo** access token e um **novo** refresh token. Substitua os dois e não faça renovações em paralelo: reutilizar um refresh já consumido revoga a sessão, e aí é preciso fazer login de novo.

### Encerrar sessão

- **URL:** `POST https://gtin.rscsistemas.com.br/api/auth/logout`
- **Corpo:** `{"refresh_token": "SEU_REFRESH_TOKEN"}`. Funciona mesmo com o access token expirado.
- **Resposta 200:** `{"mensagem": "Sessao encerrada."}`

### ✅ Exemplo cURL
```bash
curl -X POST "https://gtin.rscsistemas.com.br/api/v3/oauth/token" \
  -u "seu_usuario:sua_senha" \
  -H "Content-Length: 0" \
  -H "Accept: application/json" \
  -H "User-Agent: SeuSistema/1.0"
```

### ✅ Exemplo JavaScript (fetch)
```js
async function obterToken(usuario, senha) {
  const res = await fetch("https://gtin.rscsistemas.com.br/api/v3/oauth/token", {
    method: "POST",
    headers: {
      "Authorization": "Basic " + btoa(`${usuario}:${senha}`),
      "Accept": "application/json"
    }
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(`Falha ao obter token (${res.status}): ${data.mensagem || data.erro}`);
  }
  return data; // { access_token, refresh_token, expires_in, ... }
}
```

### ✅ Exemplo Delphi (Indy)
```delphi
uses IdHTTP, IdSSLOpenSSL, System.Classes, System.SysUtils, System.JSON;

function ObterToken(const Usuario, Senha: string): string;
var
  HTTP : TIdHTTP;
  Corpo: TStringStream;
  Json : TJSONValue;
begin
  HTTP  := TIdHTTP.Create(nil);
  Corpo := TStringStream.Create(''); // corpo vazio: o Indy envia Content-Length: 0
  try
    HTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HTTP);
    TIdSSLIOHandlerSocketOpenSSL(HTTP.IOHandler).SSLOptions.Method := sslvTLSv1_2;

    // O User-Agent padrão do Indy é recusado em POST (406): troque-o inteiro
    HTTP.Request.UserAgent := 'NomeDoSeuSistema/1.0';
    HTTP.Request.Accept    := 'application/json';
    HTTP.Request.BasicAuthentication := True;
    HTTP.Request.Username  := Usuario;
    HTTP.Request.Password  := Senha;

    Json := TJSONObject.ParseJSONValue(
      HTTP.Post('https://gtin.rscsistemas.com.br/api/v3/oauth/token', Corpo));
    try
      Result := Json.GetValue<string>('access_token');
    finally
      Json.Free;
    end;
  finally
    Corpo.Free;
    HTTP.Free;
  end;
end;
```

### ✅ Exemplo Java (HttpClient)
```java
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class AuthExample {
    public static void main(String[] args) throws Exception {
        String credenciais = Base64.getEncoder()
                .encodeToString("seu_usuario:sua_senha".getBytes(StandardCharsets.UTF_8));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://gtin.rscsistemas.com.br/api/v3/oauth/token"))
                .header("Authorization", "Basic " + credenciais)
                .header("Accept", "application/json")
                .POST(HttpRequest.BodyPublishers.noBody())
                .build();

        HttpResponse<String> response = HttpClient.newHttpClient()
                .send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            System.out.println("Token: " + response.body());
        } else {
            System.out.println("Falha ao obter token (" + response.statusCode() + "): " + response.body());
        }
    }
}
```

---

## 📦 Consultar produto (V3)

- **URL:** `GET https://gtin.rscsistemas.com.br/api/v3/gtin/{gtin}`
- **Header:** `Authorization: Bearer ACCESS_TOKEN`

Quando o GTIN é válido mas não está na base, ele é registrado para triagem e pode ser cadastrado depois.

**Resposta 200**
```json
{
  "ean": "7896116900029",
  "ean_tipo": "GTIN-13",
  "cest": "",
  "ncm": "07133399",
  "nome": "FEIJAO CARIOCA KICALDO T1 1KG",
  "nome_acento": "FEIJÃO CARIOCA KICALDO T1 1KG",
  "unid_abr": "UN",
  "unid_desc": "Unidade",
  "marca": "KICALDO",
  "pais": "Brasil",
  "categoria": "Carioca",
  "dh_update": "2026-10-10 12:00:00",
  "excluido_em": null,
  "link_foto": "https://gtin.rscsistemas.com.br/api/v3/gtin/7896116900029/image"
}
```

| Campo | Tipo | Descrição |
|---|---|---|
| `ean` | string | GTIN/EAN do produto |
| `ean_tipo` | string | Tipo do código, ex.: `GTIN-13` |
| `ncm` | string | NCM com 8 dígitos e sem pontos (formato da NF-e). Vazio quando o produto não tem NCM. **Era número nas rotas antigas: trate como texto para não perder o zero à esquerda** |
| `cest` | string | CEST, quando aplicável |
| `nome` / `nome_acento` | string | Nome normalizado / nome com acentuação para exibição |
| `unid_abr` / `unid_desc` | string | Unidade (ex.: `UN`, `CX`, `KG`) e sua descrição |
| `marca` | string | Marca comercial |
| `pais` | string | País associado ao cadastro |
| `categoria` | string | Categoria do produto |
| `dh_update` | string ou `null` | Data/hora da última atualização |
| `link_foto` | string | URL da imagem (exige o mesmo `Authorization: Bearer`) |

A plataforma informa só a classificação do produto (NCM/CEST). Alíquotas, CFOP, CST e demais regras tributárias não são guardadas nem retornadas.

### ✅ Exemplo cURL
```bash
GTIN="7896116900029"
TOKEN="SEU_TOKEN_AQUI"

curl "https://gtin.rscsistemas.com.br/api/v3/gtin/$GTIN" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  -H "User-Agent: SeuSistema/1.0"
```

### ✅ Exemplo JavaScript (fetch)
```js
async function obterInfoProduto(gtin, token) {
  const url = `https://gtin.rscsistemas.com.br/api/v3/gtin/${encodeURIComponent(gtin)}`;
  const res = await fetch(url, {
    headers: {
      "Authorization": `Bearer ${token}`,
      "Accept": "application/json"
    }
  });

  const data = await res.json();
  if (!res.ok) {
    // 400 GTIN inválido, 401 token, 403 plano/limite, 404 não encontrado, 429 suspensão
    throw new Error(`Erro ${res.status}: ${data.mensagem || data.erro}`);
  }
  return data;
}
```

### ✅ Exemplo Delphi (Indy)
```delphi
function ObterInfoProduto(const GTIN, Token: string): string;
var
  HTTP: TIdHTTP;
begin
  HTTP := TIdHTTP.Create(nil);
  try
    HTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HTTP);
    TIdSSLIOHandlerSocketOpenSSL(HTTP.IOHandler).SSLOptions.Method := sslvTLSv1_2;

    HTTP.Request.UserAgent := 'NomeDoSeuSistema/1.0';
    HTTP.Request.Accept    := 'application/json';
    HTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + Token;

    try
      Result := HTTP.Get('https://gtin.rscsistemas.com.br/api/v3/gtin/' + GTIN);
    except
      on E: EIdHTTPProtocolException do
        // E.ErrorCode = status HTTP; E.ErrorMessage = JSON com "mensagem"
        raise Exception.CreateFmt('Erro %d: %s', [E.ErrorCode, E.ErrorMessage]);
    end;
  finally
    HTTP.Free;
  end;
end;
```

### ✅ Exemplo Java (HttpClient)
```java
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class InfoProdutoExample {
    public static void main(String[] args) throws Exception {
        String gtin = "7896116900029";
        String token = "SEU_TOKEN_AQUI";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://gtin.rscsistemas.com.br/api/v3/gtin/" + gtin))
                .header("Authorization", "Bearer " + token)
                .header("Accept", "application/json")
                .GET()
                .build();

        HttpResponse<String> response = HttpClient.newHttpClient()
                .send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            System.out.println("Produto: " + response.body());
        } else {
            System.out.println("Erro " + response.statusCode() + ": " + response.body());
        }
    }
}
```

---

## 🖼️ Imagem do produto (V3)

- **URL:** `GET https://gtin.rscsistemas.com.br/api/v3/gtin/{gtin}/image`
- **Header:** `Authorization: Bearer ACCESS_TOKEN`

**Resposta 200:** corpo binário da imagem. Produto cadastrado **sem foto** também responde `200`, com a imagem padrão "produto sem imagem" (o antigo `204 No Content` não existe mais).

> O corpo pode ser **PNG ou JPEG**, mesmo com `Content-Type: image/png`. Identifique o formato pelos primeiros bytes (`89 50` = PNG, `FF D8` = JPEG). O cliente Delphi deste repositório faz isso em `CarregarImagem`, e no Lazarus o `TPicture.LoadFromStream` identifica sozinho.

**404:** `{"mensagem": "Produto não encontrado na base de dados"}`

### ✅ Exemplo cURL (salvar arquivo)
```bash
curl "https://gtin.rscsistemas.com.br/api/v3/gtin/$GTIN/image" \
  -H "Authorization: Bearer $TOKEN" \
  -H "User-Agent: SeuSistema/1.0" \
  --output "$GTIN.img"
```

### ✅ Exemplo JavaScript (fetch)
```js
async function exibirImagem(gtin, token, elementoImg) {
  const url = `https://gtin.rscsistemas.com.br/api/v3/gtin/${encodeURIComponent(gtin)}/image`;
  const res = await fetch(url, { headers: { "Authorization": `Bearer ${token}` } });

  if (!res.ok) {
    const err = await res.json();
    throw new Error(`Erro ${res.status}: ${err.mensagem}`);
  }
  elementoImg.src = URL.createObjectURL(await res.blob());
}
```

### ✅ Exemplo Delphi (Indy)
```delphi
procedure BaixarImagem(const GTIN, Token: string; Destino: TStream);
var
  HTTP: TIdHTTP;
begin
  HTTP := TIdHTTP.Create(nil);
  try
    HTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HTTP);
    TIdSSLIOHandlerSocketOpenSSL(HTTP.IOHandler).SSLOptions.Method := sslvTLSv1_2;

    HTTP.Request.UserAgent := 'NomeDoSeuSistema/1.0';
    HTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + Token;
    HTTP.Get('https://gtin.rscsistemas.com.br/api/v3/gtin/' + GTIN + '/image', Destino);
    Destino.Position := 0; // PNG ou JPEG: veja CarregarImagem no cliente Delphi
  finally
    HTTP.Free;
  end;
end;
```

### ✅ Exemplo Java (HttpClient)
```java
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;

public class ImagemProdutoExample {
    public static void main(String[] args) throws Exception {
        String gtin = "7896116900029";
        String token = "SEU_TOKEN_AQUI";

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://gtin.rscsistemas.com.br/api/v3/gtin/" + gtin + "/image"))
                .header("Authorization", "Bearer " + token)
                .GET()
                .build();

        HttpResponse<byte[]> response = HttpClient.newHttpClient()
                .send(request, HttpResponse.BodyHandlers.ofByteArray());

        if (response.statusCode() == 200) {
            byte[] img = response.body();
            String ext = (img.length > 1 && (img[0] & 0xFF) == 0xFF && (img[1] & 0xFF) == 0xD8) ? ".jpg" : ".png";
            Path destino = Path.of(gtin + ext);
            Files.write(destino, img);
            System.out.println("Imagem salva em: " + destino.toAbsolutePath());
        } else {
            System.out.println("Erro " + response.statusCode() + ": " + new String(response.body()));
        }
    }
}
```

---

## 🧬 API V4

### Consultar produto V4

- **URL:** `GET https://gtin.rscsistemas.com.br/api/v4/gtin/{gtin}`
- **Header:** `Authorization: Bearer ACCESS_TOKEN`

**Resposta 200** (resumida)
```json
{
  "schema_versao": "1.0.0",
  "status": "encontrado",
  "gtin_consultado": "7896116900029",
  "produto": {
    "gtin": "7896116900029",
    "tipo_produto": "produto_padrao",
    "categoria": "Bebidas",
    "subcategoria": "Refrigerantes",
    "nome": "Produto exemplo 2L",
    "descricao_completa": "Refrigerante sabor exemplo, garrafa 2 litros.",
    "descricao_reduzida": "Refrigerante exemplo 2L",
    "marca": "Marca exemplo",
    "fabricante": { "nome": "Fabricante Exemplo LTDA", "cnpj": "11222333000181" },
    "conteudo": { "quantidade": 2, "unidade": "L", "quantidade_unidades": 1 },
    "embalagem": { "tipo": "Garrafa", "material": "PET" },
    "unidade_comercial": { "codigo": "UN", "descricao": "Unidade", "fator_conversao": 1 },
    "classificacao_fiscal": { "ncm": "22021000", "descricao_ncm": "...", "cest": "0300100" },
    "atributos_adicionais": {},
    "link_foto": "https://gtin.rscsistemas.com.br/api/v4/gtin/7896116900029/image?size=500",
    "imagens": [
      { "principal": true, "ordem": 1, "tamanhos": { "100": "https://...", "250": "https://...", "500": "https://..." } }
    ]
  },
  "validacao_gtin": { "formato": "GTIN-13" },
  "qualidade_dados": { "confianca": "alta" }
}
```

| Grupo (dentro de `produto`) | Contém |
|---|---|
| `fabricante` | nome e CNPJ do fabricante |
| `conteudo` | quantidade, unidade e quantidade de unidades por embalagem |
| `embalagem` | tipo e material da embalagem |
| `unidade_comercial` | código, descrição e fator de conversão da unidade de venda |
| `classificacao_fiscal` | NCM, descrição do NCM e CEST |
| `atributos_adicionais` | atributos livres específicos do produto |
| `imagens` | lista com `principal`, `ordem` e `tamanhos` (100, 250 e 500 px) |

`validacao_gtin` e `qualidade_dados` ficam no nível raiz, fora de `produto`.

### Imagem V4

- **URL:** `GET https://gtin.rscsistemas.com.br/api/v4/gtin/{gtin}/image?size=250`
- `size` aceita `100`, `250` ou `500`. Qualquer outro valor usa `500`.
- Retorna `image/png` ou `image/jpeg`. Sem foto cadastrada, retorna a imagem padrão "produto sem imagem".

As rotas de escrita (cadastrar, atualizar, importar, excluir, restaurar produto e reprocessar via IA) exigem permissão de gravação na conta e estão na [documentação oficial](https://gtin.rscsistemas.com.br/documentacao).

---

## 🚨 Erros

Os erros vêm em JSON, com `mensagem` (ou `erro`) e, em alguns casos, `motivo` e `ajuda` (link da página que explica como resolver). Valem igualmente para V3 e V4.

| Status | Quando ocorre | Exemplo |
|---|---|---|
| `400` | Cabeçalho Basic ausente ou JSON inválido | `{"mensagem":"Cabeçalho de autorização inválido"}` |
| `400` | GTIN inválido: fora do formato ou com dígito verificador errado (e sem cadastro). `motivo`: `formato` ou `digito_verificador` | `{"mensagem":"GTIN invalido: digito verificador nao confere.","motivo":"digito_verificador","ajuda":"https://gtin.rscsistemas.com.br/gtin-valido"}` |
| `401` | Token ausente, inválido ou expirado, ou credenciais incorretas | `{"mensagem":"Token inválido!"}` |
| `403` | Limite do plano atingido, versão da API não liberada no plano ou consultas limitadas por uso das rotas antigas (`limite_rota_antiga`) | `{"erro":"Seu plano não permite acesso à API V4. ..."}` |
| `403` | Termos de Uso e Política de Privacidade não aceitos depois do prazo. `motivo`: `termos_pendentes`. O aceite é feito ao entrar na área do cliente | `{"mensagem":"Aceite os Termos de Uso ...","motivo":"termos_pendentes","aceite_url":"https://gtin.rscsistemas.com.br/login"}` |
| `404` | GTIN não encontrado na base | `{"mensagem":"Produto não encontrado"}` |
| `404` | GTIN válido que não identifica produto global: códigos internos de loja/peso variável (prefixo 200–299), cupons, ISSN (977). Não entra na fila de cadastro. `motivo`: `circulacao_restrita`, `cupom` ou `issn` | `{"mensagem":"Codigo de circulacao restrita ...","motivo":"circulacao_restrita"}` |
| `406` | Recusado pelo firewall antes de chegar na API (resposta HTML, não JSON) | veja a seção abaixo |
| `429` | Muitas tentativas de login, ou consultas suspensas por envio repetido de GTIN inválido (1 h, depois 6 h e 24 h em caso de reincidência em 7 dias). Traz `Retry-After`, `motivo: suspenso_gtin_invalido` e `liberado_em`. Token e gravação continuam funcionando | `{"mensagem":"Consultas suspensas ate ...","motivo":"suspenso_gtin_invalido","retry_after":3540}` |
| `500` | Erro interno | `{"mensagem":"Erro interno do servidor."}` |

---

## 🧱 Erro 406 Not Acceptable (firewall da hospedagem)

O firewall do servidor (ModSecurity) recusa algumas requisições **antes** de elas chegarem na API. A resposta é uma página HTML (*"Not Acceptable! ... generated by Mod_Security"*), sem JSON, e a chamada não aparece no histórico da sua conta. Isso acontece em dois casos:

1. **POST sem o cabeçalho `Content-Length`**, como o pedido de token, que não tem corpo. Envie `Content-Length: 0` (ou um corpo vazio, para a biblioteca mandar o cabeçalho). GET, PUT e DELETE não são afetados.
2. **User-Agent padrão de algumas bibliotecas:**
   - Delphi/Indy (`Mozilla/3.0 (compatible; Indy Library)`): recusado em POST. **Acrescentar texto ao User-Agent do Indy não basta: troque-o inteiro**, ex.: `IdHTTP1.Request.UserAgent := 'NomeDoSeuSistema/1.0';`
   - `python-requests`, `Python-urllib` e `Go-http-client`: recusados em qualquer chamada.

Funcionam sem ajuste, entre outros: navegadores e `fetch`, Node, axios, PHP Guzzle, Java, okhttp, .NET (HttpClient, RestSharp), PowerShell, Postman, `python-httpx` e o `TNetHTTPClient` do Delphi.

---

## ✔️ Validar o GTIN antes de consultar

A API aceita GTIN-8, GTIN-12, GTIN-13 e GTIN-14: **somente dígitos**, não todo zero e com o **dígito verificador GS1** correto (módulo 10, pesos 3 e 1 alternados da direita para a esquerda, sem contar o último dígito). Validar localmente evita a suspensão `429` por GTIN inválido repetido. Veja a explicação e um verificador em [/gtin-valido](https://gtin.rscsistemas.com.br/gtin-valido).

```delphi
function GTINValido(const GTIN: string): Boolean;
var
  I, Soma, Peso: Integer;
begin
  Result := False;
  case Length(GTIN) of
    8, 12, 13, 14: ;
  else
    Exit;
  end;
  for I := 1 to Length(GTIN) do
    if not CharInSet(GTIN[I], ['0'..'9']) then
      Exit;
  if GTIN = StringOfChar('0', Length(GTIN)) then
    Exit;

  Soma := 0;
  Peso := 3;
  for I := Length(GTIN) - 1 downto 1 do
  begin
    Soma := Soma + (Ord(GTIN[I]) - Ord('0')) * Peso;
    Peso := 4 - Peso;
  end;
  Result := ((10 - Soma mod 10) mod 10) = (Ord(GTIN[Length(GTIN)]) - Ord('0'));
end;
```

---

## 🧠 Boas Práticas

- Use as rotas versionadas (`/api/v3/...` ou `/api/v4/...`). As rotas sem versão foram removidas.
- Defina um **User-Agent próprio** e envie `Content-Length: 0` nos POST sem corpo.
- Reaproveite o access token enquanto ele valer (`expires_in`) e renove com o `refresh_token`. Não peça um token novo a cada consulta.
- Valide o GTIN localmente (formato e dígito verificador) antes de consultar.
- Trate `ncm` como texto e campos que podem vir `null`, como `dh_update`.
- Leia `mensagem`/`erro`, `motivo` e `ajuda` das respostas de erro para orientar o usuário.
- Em `429`, respeite o cabeçalho `Retry-After` antes de tentar de novo.

---

**Desenvolvido por RSC Sistemas**
🌐 [https://rscsistemas.com.br](https://rscsistemas.com.br)

**Roniery Santos Cardoso**
📧 E-mail: [roniery@rscsistemas.com.br](mailto:roniery@rscsistemas.com.br)
📱 WhatsApp: [+55 92 4141-2737](https://wa.me/559241412737)
