# demo-API-GTIN

OSCBR - Open Source Community Brasil

Como utilizar

Base URL: https://oscbr.com.br:9092

Endpoints:



<details>

<summary>/gettoken</summary>

Descrição: Endpoint usando para solicitação do token de acesso, tendo como parametros HEADERS:
** username
** password

exemplo URL: https://oscbr.com.br:9092/gettoken

Se tudo ocorrer certo um json será retornado contendo o token de aesso aos demais endpoints da api.

Json de retorno:

'''
{
    "token": "eyJhbGciOiAiQUVTMjU2IiwgInR5cCI6ICJKV1QifQ==.eyJpc3MiOiJTMkFURnE4OGdtVEsiLCAiZXhwIjoiMTY4MzUyODg0NiIsICJpYXQiOiIxNjgzNTI4NjY2IiwgInNlY3JldHMiOiJleUp6WldOeVpYUnpJam9pWlhsS2NGcERTVFpKYWtVMVNXbDNaMGx1VGpCWldGSXhZM2xKTmtscVJXbE1RMEZwWkVkc2QySXhPVEZqTTFab1kyMXNka2xxYjJsTlUwbzVJaXdnSW0xa05TSTZJakl3UVRjNU5UQXdNREF3TURBd01EQkdORVl3TVVJd01UWXdNVU5DTURBeUluMD0ifQ==.fLS55zjO9i0/rrjSYiYZbZyB64HGawU53QG9szrF5tT4TpJi6O8Md8sCBiwx9u90CR8mSmo37ovGeZ29vJMrKxtHgSBdI1kI/f+dYAhQ/60DitS9fGN3qIynL+OByhAk6UL1TQTTO2+48wa1ioLtwA+Un1lWDFW0MON55C0a1+z9ZH1Yya8FnoZUk3fMx5Syt4z5ZbeNQVwWrBcS2LGXd8OaDHeTRF70RaNTMW09vRoqgsEWyIOEXs0ZLtPkj70Mzc1QAGfpZ/KSsFIVOovuvf5gu9kV4+b6tVMDyIwn3WEcdEUM39DhPZ3UueQn48mcYASXEs9CZtxjXtcfuXehHike/ULaW2qvuYM7iVDcAPwBuH57LX44zj90oo4JTI1LzkAiedIE61mTS0GYQexl8uWEbD25Hv2smWynuMKt1QxRKBdOdc5abnV0vMu0DJv7go42twLfYSb1u4baZg7vuKCyLrAt"
}
'''

</details>
