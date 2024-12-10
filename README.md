# Client-API-GTIN

### OSCBR - Open Source Community Brasil

Site: https://gtin.rscsistemas.com.br

### Para fazer uso da API GTIN precisará de um usuário e senha, caso ainda não tenha feito poderá esta fazendo seu cadastro acesssando o link abaixo:
Cadastre-se: https://gtin.rscsistemas.com.br/cadastro

<main class="flex-shrink-0">
    <div class="container">
        <div class="row row-rsc">
            <div class="col-10" style="text-align: center;">
                <h2>Documentação API GTIN V1.0.1</h2>
                <h4>A seguir poderá encontrar todo o passo a passo para fezer uso de nossa api.</h4>
            </div>
        </div>
        <section>
            <div class="row">
                <div class="col-10">
                    <h3 style="color: green; text-align: center;">Obter token Bearer</h3>
                </div>
            </div>
            <div class="row row-rsc">
                <div class="col-10" style="text-align: left;">
                    <p>O Token gerado será necessário para consumir os endpoints da API GTIN.</p>
                    <ol>
                        <li>
                            <p>O tempo de vida de um token gerado é de uma hora. Com isso, é possível realizar um número determinado de requisições nas apis, de acordo com o rate limit de cada api, utilizando um único token.</p>
                        </li>
                        <li>
                            <p>Rate limit: 20 chamadas por minuto para o plano free, que esta em vigor atualmente.</p>
                        </li>
                    </ol>
                </div>
            </div>
            <div class="row">
                <div class="col">
                    <div class="card" style="background-color: aliceblue !important;">
                        <div class="card-header"><strong>/oauth/token</strong></div>
                        <div class="card-body">
                            <p class="card-text">Endpoint de solicitação do token Bearer de acesso.</p>
                            <p class="card-text">URL: https://gtin.rscsistemas.com.br/oauth/token</p>
                        </div>
                        <div class="card-header"><strong>Paramêtros</strong></div>
                        <div class="card-body">
                            <h5 style="color: darkorange;">username</h5>
                            <h5 style="font-size: 65%; color: darkred;">Requerido</h5>
                            <h6 class="card-text" style="color: dimgrey;">string (header)</h6>
                            <h5 style="color: darkorange;">password</h5>
                            <h5 style="font-size: 65%; color: darkred;">Requerido</h5>
                            <h6 class="card-text" style="color: dimgrey;">string (header)</h6>
                        </div>
                        <div class="card-header"><strong>Respostas</strong></div>
                        <div class="card-body">
                            <h5 style="color: darkcyan;">Código 200:</h5>
                            <p class="card-text">A requisição foi processada com sucesso.</p>
                            <h5 class="card-title" style="color: darkcyan;">Token Gerado</h5>
                            <p class="card-text">Media type: <strong>application/json</strong></p>
                            <pre><code>{"token":"eyJhbGciOiAiQUVTMjU2IiwgInR5cCI6ICJKV1QifQ==.eyJpc3MiOiJTMkFURnE4OGdtVEsiLCAiZXhwIjoiMTY4MzUyODg0NiIsICJpYXQiOiIxNjgzNTI4NjY2IiwgInNlY3JldHMiOiJleUp6WldOeVpYUnpJam9pWlhsS2NGcERTVFpKYWtVMVNXbDNaMGx1VGpCWldGSXhZM2xKTmtscVJXbE1RMEZwWkVkc2QySXhPVEZqTTFab1kyMXNka2xxYjJsTlUwbzVJaXdnSW0xa05TSTZJakl3UVRjNU5UQXdNREF3TURBd01EQkdORVl3TVVJd01UWXdNVU5DTURBeUluMD0ifQ==.fLS55zjO9i0/rrjSYiYZbZyB64HGawU53QG9szrF5tT4TpJi6O8Md8sCBiwx9u90CR8mSmo37ovGeZ29vJMrKxtHgSBdI1kI/f+dYAhQ/60DitS9fGN3qIynL+OByhAk6UL1TQTTO2+48wa1ioLtwA+Un1lWDFW0MON55C0a1+z9ZH1Yya8FnoZUk3fMx5Syt4z5ZbeNQVwWrBcS2LGXd8OaDHeTRF70RaNTMW09vRoqgsEWyIOEXs0ZLtPkj70Mzc1QAGfpZ/KSsFIVOovuvf5gu9kV4+b6tVMDyIwn3WEcdEUM39DhPZ3UueQn48mcYASXEs9CZtxjXtcfuXehHike/ULaW2qvuYM7iVDcAPwBuH57LX44zj90oo4JTI1LzkAiedIE61mTS0GYQexl8uWEbD25Hv2smWynuMKt1QxRKBdOdc5abnV0vMu0DJv7go42twLfYSb1u4baZg7vuKCyLrAt"}</code></pre>
                        </div>
                        <div class="card-body">
                            <h5 style="color: darkgoldenrod;">Código 401:</h5>
                            <p class="card-text">Não autenticado</p>
                            <p class="card-text">Os dados de autenticação estão incorretos. Verifique no cabeçalho (header) da requisição.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        <br><br>
            <div class="row">
                <div class="col-10">
                    <h3 style="color: green; text-align: center;">Obter Informaçãoes do produto</h3>
                </div>
            </div>
            <div class="row row-rsc">
                <div class="col-10" style="text-align: left;">
                    <p>Com o Token gerado anteriormente agora você pode fazer chamada a api usando o mesmo token até que o mesmo se expire.</p>
                </div>
            </div>
            <div class="row">
                <div class="col">
                    <div class="card" style="background-color: aliceblue !important;">
                        <div class="card-header"> <strong>/api/gtin/infor/:gtin</strong></div>
                        <div class="card-body">
                            <p class="card-text">Endpoint de solicitação das informações de um determinado produto atravez do seu EAN/GTIN.</p>
                            <p class="card-text">URL: https://gtin.rscsistemas.com.br/api/gtin/infor/:gtin</p>
                        </div>
                        <div class="card-header"><strong>Paramêtros</strong></div>
                        <div class="card-body">
                            <h5 style="color: darkorange;">gtin</h5>
                            <h5 style="font-size: 65%; color: darkred;">Requerido</h5>
                            <h6 class="card-text" style="color: dimgrey;">string (query)</h6>
                        </div>
                        <div class="card-header"><strong>Respostas</strong></div>
                        <div class="card-body">
                            <h5 class="card-title" style="color: darkcyan;">Código 200:</h5>
                            <p class="card-text">A requisição foi processada com sucesso.</p>
                            <h5 class="card-title" style="color: darkcyan;">Retorno header:</h5>
                            <p class="card-text">Media type: <strong>application/json</strong></p>
                            <pre><code>{
    "ean": "7896116900029",
    "ean_tipo": "EAN13",
    "cest": "",
    "ncm": 7133399,
    "nome": "FEIJAO CARIOCA KICALDO T1 1KG",
    "nome_acento": "FEIJÃO CARIOCA TIPO 1 KICALDO PACOTE 1KG",
    "unid_abr": "KG",
    "unid_desc": "QUILOGRAMA",
    "marca": "KICALDO",
    "pais": "BRASIL",
    "categoria": "Carioca",
    "dh_update": "16/05/2023 22:06:29",
    "link_foto": "https://gtin.rscsistemas.com.br/api/gtin/img/7896116900029"
}</code></pre>
                        </div>
                        <div class="card-body">
                            <h5 style="color: darkgoldenrod;">Código 405:</h5>
                            <p class="card-text">Não encontrado</p>
                            <p class="card-text">O produto para qual solicitou informaçãoes não foi encontrado em nossas bases de dados.</p>
                            <h5 class="card-title" style="color: darkcyan;">Retorno header:</h5>
                            <p class="card-text">Media type: <strong>application/json</strong></p>
                            <pre><code>{
    "ean": "405",
    "ean_tipo": "405",
    "cest": "405",
    "ncm": 405,
    "nome": "405",
    "nome_acento": "405",
    "unid_abr": "405",
    "unid_desc": "405",
    "marca": "405",
    "pais": "405",
    "categoria": "405",
    "dh_update": "405",
    "link_foto": "405"
}</code></pre>
                        </div>
                    </div>
                    </div>
                </div>
            </div>
          <br><br>
            <div class="row">
                <div class="col-10">
                    <h3 style="color: green; text-align: center;">Obter Imagem do produto</h3>
                </div>
            </div>
            <div class="row row-rsc">
                <div class="col-10" style="text-align: left;">
                    <p>Com o Token gerado anteriormente agora você pode fazer chamada a api usando o mesmo token até que o mesmo se expire.</p>
                </div>
            </div>
            <div class="row">
                <div class="col">
                    <div class="card" style="background-color: aliceblue !important;">
                        <div class="card-header"><strong>/api/gtin/img/:gtin</strong></div>
                        <div class="card-body">
                            <p class="card-text">Endpoint de solicitação a imagem do produto</p>
                            <p class="card-text">URL: https://gtin.rscsistemas.com.br/api/gtin/img/:gtin</p>
                        </div>
                        <div class="card-header"><strong>Paramêtros</strong></div>
                        <div class="card-body">
                            <h5 style="color: darkorange;">gtin</h5>
                            <h5 style="font-size: 65%; color: darkred;">Requerido</h5>
                            <h6 class="card-text" style="color: dimgrey;">string (query)</h6>
                        </div>
                        <div class="card-header"><strong>Respostas</strong></div>
                        <div class="card-body">
                            <h5 style="color: darkcyan;">Código 200:</h5>
                            <p class="card-text">A requisição foi processada com sucesso.</p>
                            <h5 class="card-title" style="color: darkcyan;">Retorno body:</h5>
                            <p class="card-text">Media type: <strong>image/x-png</strong></p>
                            <div class="row">
                                <div class="col" style="text-align: center;">
                                    <img style="height: 300px; width: auto;" src="https://gtin.rscsistemas.com.br/7896116900029500pxpng" alt="Feijao-Carioca-Tipo-1-KICALDO-Pacote-1kg">
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <h5 style="color: darkgoldenrod;">Código 400:</h5>
                            <p class="card-text">Requisição mal formada </p>
                            <p class="card-text">A requisição não está de acordo com o formato esperado. Verifique se realmente passou o EAN/GTIN na url da requisição.</p>
                        </div>
                        <div class="card-body">
                            <h5 style="color: darkgoldenrod;">Código 404:</h5>
                            <p class="card-text">Não encontrado</p>
                            <p class="card-text">O produto para qual solicitou a imgagem não foi encontrado em nossas bases de dados.</p>
                            <h5 class="card-title" style="color: darkcyan;">Retorno body:</h5>
                            <p class="card-text">Media type: <strong>image/x-png</strong></p>
                            <div class="row">
                                <div class="col" style="text-align: center;">
                                    <img style="height: 300px; width: auto;" src="https://gtin.rscsistemas.com.br/produto_sem_imagem500pxpng" alt="Produto não encontrado">
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <h5 style="color: darkgoldenrod;">Código 204:</h5>
                            <p class="card-text">Sem conteúdo</p>
                            <p class="card-text">Não foi encontrado uma imagem para o produto informado. </p>
                            <h5 class="card-title" style="color: darkcyan;">Retorno body:</h5>
                            <p class="card-text">Media type: <strong>image/x-png</strong></p>
                            <div class="row">
                                <div class="col" style="text-align: center;">
                                    <img style="height: 300px; width: auto;" src="https://gtin.rscsistemas.com.br/produto_sem_imagem500pxpng" alt="Produto sem imagem">
                                </div>
                            </div>
                        </div>
                    </div:
                </div>
            </div> 
</main>
