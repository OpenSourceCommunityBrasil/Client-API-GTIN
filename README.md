# 📃 Client API GTIN

### OSCBR - Open Source Community Brasil  
🌐 **Site:** [https://gtin.rscsistemas.com.br](https://gtin.rscsistemas.com.br)

---

## 📋 Cadastro e Autenticação

Para utilizar a **API GTIN**, é necessário possuir um usuário e senha.  
Se ainda não tiver, cadastre-se em:  
🔗 [https://gtin.rscsistemas.com.br/cadastro](https://gtin.rscsistemas.com.br/cadastro)

---

## 🔐 Autenticação e Token

### Endpoint
- **URL:** `https://gtin.rscsistemas.com.br/oauth/token`  
- **Método:** `POST`  
- **Headers obrigatórios:**
  - `Authorization: Basic <base64_encoded_credentials>` (onde as credenciais `username:password` são codificadas em base64)
  - `Accept: application/json`

**Observações**
- O token expira em **1 hora**.
- **Rate limit:** 20 req/min (plano Free).

### ✅ Exemplo cURL
```bash
curl -X POST "https://gtin.rscsistemas.com.br/oauth/token" \
  -H "Authorization: Basic <base64_encoded_credentials>" \
  -H "Accept: application/json"
```

### ✅ Exemplo JavaScript (fetch)
```js
async function obterToken() {
  const res = await fetch("https://gtin.rscsistemas.com.br/oauth/token", {
    method: "POST",
    headers: {
      "Authorization": "Basic <base64_encoded_credentials>", // Substitua pelo valor codificado em base64
      "Accept": "application/json"
    }
  });

  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`Falha ao obter token (${res.status}): ${txt}`);
  }
  const data = await res.json();
  return data.token; // string
}
```

### ✅ Exemplo Delphi (Indy)
```delphi
uses IdHTTP, System.SysUtils;

function ObterToken: string;
var
  HTTP: TIdHTTP;
  Resp: string;
begin
  HTTP := TIdHTTP.Create(nil);
  try
    HTTP.Request.CustomHeaders.Values['Authorization'] := 'Basic <base64_encoded_credentials>'; // Substitua pelo valor codificado em base64
    HTTP.Request.Accept := 'application/json';

    Resp := HTTP.Post('https://gtin.rscsistemas.com.br/oauth/token', nil);
    Result := Resp;
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

public class AuthExample {
    public static void main(String[] args) throws Exception {
        String url = "https://gtin.rscsistemas.com.br/oauth/token";
        String credentials = "<base64_encoded_credentials>"; // Substitua pelo valor codificado em base64

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Basic " + credentials)
                .header("Accept", "application/json")
                .POST(HttpRequest.BodyPublishers.noBody())
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            System.out.println("Token: " + response.body());
        } else {
            System.out.println("Falha ao obter token: " + response.body());
        }
    }
}
```

### Respostas
- **200 OK**
```json
{ "token": "eyJhbGciOiAiQUVTMjU2IiwgInR5cCI6ICJKV1QifQ==..." }
```
- **401 Unauthorized**
```json
{ "erro": "Não autenticado. Verifique suas credenciais." }
```

---

## 📦 Informações do Produto

### Endpoint
- **URL:** `https://gtin.rscsistemas.com.br/api/gtin/infor/:gtin`  
- **Método:** `GET`  
- **Path param:** `:gtin` (string)  
- **Header:** `Authorization: Bearer <SEU_TOKEN>`

### ✅ Exemplo cURL
```bash
GTIN="7896116900029"
TOKEN="SEU_TOKEN_AQUI"

curl -X GET "https://gtin.rscsistemas.com.br/api/gtin/infor/$GTIN" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

### ✅ Exemplo JavaScript (fetch)
```js
async function obterInfoProduto(gtin, token) {
  const url = `https://gtin.rscsistemas.com.br/api/gtin/infor/${encodeURIComponent(gtin)}`;
  const res = await fetch(url, {
    headers: {
      "Authorization": `Bearer ${token}`,
      "Accept": "application/json"
    }
  });

  if (res.status === 404) {
    const err = await res.json();
    throw new Error(err.mensagem || "Produto não encontrado");
  }
  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`Erro ${res.status}: ${txt}`);
  }
  return res.json();
}
```

### ✅ Exemplo Delphi (Indy)
```delphi
function ObterInfoProduto(const GTIN, Token: string): string;
var
  HTTP: TIdHTTP;
  URL: string;
begin
  HTTP := TIdHTTP.Create(nil);
  try
    HTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + Token;
    HTTP.Request.Accept := 'application/json';

    URL := Format('https://gtin.rscsistemas.com.br/api/gtin/infor/%s', [GTIN]);
    Result := HTTP.Get(URL);
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
        String url = "https://gtin.rscsistemas.com.br/api/gtin/infor/" + gtin;

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bearer " + token)
                .header("Accept", "application/json")
                .GET()
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            System.out.println("Produto: " + response.body());
        } else {
            System.out.println("Erro: " + response.body());
        }
    }
}
```

### Respostas
- **200 OK**
```json
{
  "ean": "7896116900029",
  "ean_tipo": "EAN13",
  "ncm": 7133399,
  "nome": "FEIJAO CARIOCA KICALDO T1 1KG",
  "marca": "KICALDO",
  "pais": "BRASIL",
  "categoria": "Carioca",
  "link_foto": "https://gtin.rscsistemas.com.br/api/gtin/img/7896116900029"
}
```

- **404 Not Found**
```json
{ "mensagem": "Produto não encontrado na base de dados" }
```

---

## 🖼️ Imagem do Produto

### Endpoint
- **URL:** `https://gtin.rscsistemas.com.br/api/gtin/img/:gtin`  
- **Método:** `GET`  
- **Path param:** `:gtin` (string)  
- **Header:** `Authorization: Bearer <SEU_TOKEN>`

### ✅ Exemplo cURL (salvar arquivo)
```bash
GTIN="7896116900029"
TOKEN="SEU_TOKEN_AQUI"

curl -L "https://gtin.rscsistemas.com.br/api/gtin/img/$GTIN" \
  -H "Authorization: Bearer $TOKEN" \
  --output "${GTIN}.png"
```

### ✅ Exemplo JavaScript (fetch)
```js
async function baixarImagem(gtin, token) {
  const url = `https://gtin.rscsistemas.com.br/api/gtin/img/${encodeURIComponent(gtin)}`;
  const res = await fetch(url, {
    headers: { "Authorization": `Bearer ${token}` }
  });

  if (res.status === 404) {
    const err = await res.json();
    throw new Error(err.mensagem || "Produto não encontrado na base de dados");
  }
  if (res.status === 204) {
    throw new Error("Produto encontrado, porem sem imagem cadastrada");
  }
  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`Erro ${res.status}: ${txt}`);
  }

  const blob = await res.blob();
  const urlBlob = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = urlBlob;
  a.download = `${gtin}.png`;
  a.click();
  URL.revokeObjectURL(urlBlob);
}
```

### ✅ Exemplo Delphi (Indy)
```delphi
procedure BaixarImagem(const GTIN, Token, CaminhoDestino: string);
var
  HTTP: TIdHTTP;
  FileStream: TFileStream;
  URL: string;
begin
  HTTP := TIdHTTP.Create(nil);
  try
    HTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + Token;
    URL := Format('https://gtin.rscsistemas.com.br/api/gtin/img/%s', [GTIN]);
    FileStream := TFileStream.Create(CaminhoDestino + GTIN + '.png', fmCreate);
    try
      HTTP.Get(URL, FileStream);
    finally
      FileStream.Free;
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
import java.nio.file.Path;
import java.nio.file.Paths;

public class ImagemProdutoExample {
    public static void main(String[] args) throws Exception {
        String gtin = "7896116900029";
        String token = "SEU_TOKEN_AQUI";
        String url = "https://gtin.rscsistemas.com.br/api/gtin/img/" + gtin;

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bearer " + token)
                .GET()
                .build();

        Path caminhoDestino = Paths.get(gtin + ".png");
        HttpResponse<Path> response = client.send(request, HttpResponse.BodyHandlers.ofFile(caminhoDestino));

        if (response.statusCode() == 200) {
            System.out.println("Imagem salva em: " + caminhoDestino.toAbsolutePath());
        } else if (response.statusCode() == 204) {
            System.out.println("Produto encontrado, porem sem imagem cadastrada");
        } else if (response.statusCode() == 404) {
            System.out.println("Produto não encontrado na base de dados");
        } else {
            System.out.println("Erro ao baixar imagem. Status: " + response.statusCode());
        }
    }
}
```

### Respostas
- **200 OK** → `image/png`

**Exemplo de imagem retornada:**  
![Exemplo de imagem](https://gtin.rscsistemas.com.br/7896116900029500pxpng)

- **404 Not Found**
```json
{ "mensagem": "Produto não encontrado na base de dados" }
```

- **204 No Content**

**Imagem exemplo para 204:**  
![Produto sem imagem](https://gtin.rscsistemas.com.br/produto_sem_imagem500pxpng)

---

## 🧠 Boas Práticas
- Sempre envie o header `Authorization: Bearer <token>` nos endpoints protegidos.  
- Trate a expiração do token solicitando um novo via `/oauth/token`.  
- Valide o GTIN localmente antes de consultar.  
- Utilize `Accept: application/json` para respostas estruturadas.

---

**Desenvolvido por RSC Sistemas**  
🌐 [https://rscsistemas.com.br](https://rscsistemas.com.br)  

**Roniery Santos Cardoso**  
📧 E-mail: [roniery@rscsistemas.com.br](mailto:roniery@rscsistemas.com.br)  
📱 WhatsApp: [+55 92 4141-2737](https://wa.me/559241412737)  

