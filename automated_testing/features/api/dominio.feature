# language: pt
@api @regression @domain
Funcionalidade: Caracteres de domínio
  Como responsável pela API
  Quero aceitar somente valores dentro do domínio de cada campo
  Para rejeitar entradas inválidas antes de processá-las

  # Os marcadores {..._unico} geram valores novos da mesma classe de caracteres,
  # para que o cenário possa ser repetido no mesmo banco.
  Esquema do Cenário: <id> - <titulo>
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "<nome>", "password": "senhaValida1" }
      """
    Então o status da resposta deve ser 201

    Exemplos:
      | id             | titulo             | nome                |
      | CT-API-DOM-001 | Somente minúsculas | {minusculas_unico}  |
      | CT-API-DOM-002 | Somente maiúsculas | {maiusculas_unico}  |
      | CT-API-DOM-003 | Somente números    | {numeros_unico}     |
      | CT-API-DOM-004 | Somente sublinhado | {sublinhados_livre} |
      | CT-API-DOM-005 | Combinação válida  | {combinacao_unica}  |

  # Os valores estão em formato JSON. Na tabela, \\ representa uma barra invertida.
  Esquema do Cenário: <id> - <titulo>
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": <valor>, "password": "senhaValida1" }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"

    Exemplos:
      | id             | titulo                 | valor            |
      | CT-API-DOM-010 | Texto vazio            | ""               |
      | CT-API-DOM-011 | Espaço interno         | "ana maria"      |
      | CT-API-DOM-012 | Espaço no início       | " anamaria"      |
      | CT-API-DOM-013 | Espaço no fim          | "anamaria "      |
      | CT-API-DOM-014 | Quebra de linha no fim | "anamaria\\n"    |
      | CT-API-DOM-015 | Tabulação              | "ana\\tmaria"    |
      | CT-API-DOM-016 | Hífen                  | "ana-maria"      |
      | CT-API-DOM-017 | Ponto                  | "ana.maria"      |
      | CT-API-DOM-018 | Arroba                 | "ana@maria"      |
      | CT-API-DOM-019 | Acento                 | "joão"           |
      | CT-API-DOM-020 | Cedilha                | "cauçao"         |
      | CT-API-DOM-021 | Emoji                  | "ana😀"          |
      | CT-API-DOM-022 | Aspas simples          | "ana'maria"      |
      | CT-API-DOM-023 | Aspas duplas           | "ana\"maria"     |
      | CT-API-DOM-024 | Ponto e vírgula        | "ana;maria"      |
      | CT-API-DOM-025 | Porcentagem            | "ana%maria"      |
      | CT-API-DOM-026 | Barras                 | "ana/maria\\\\x" |
      | CT-API-DOM-027 | Marcação HTML          | "<b>ana</b>"     |
      | CT-API-DOM-028 | Tipo número            | 123456           |
      | CT-API-DOM-029 | Tipo nulo              | null             |
      | CT-API-DOM-030 | Tipo lista             | ["ana_maria"]    |

  Esquema do Cenário: <id> - <titulo>
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{nome_unico}", "password": "<senha>" }
      """
    Então o status da resposta deve ser 201
    E o login com as credenciais enviadas deve ter status 200

    Exemplos:
      | id             | titulo            | senha            |
      | CT-API-DOM-040 | Símbolos          | !@#$%^&*()       |
      | CT-API-DOM-041 | Acentos e cedilha | açãoÉótima       |
      | CT-API-DOM-042 | Espaços           | senha com espaco |
      | CT-API-DOM-043 | Emoji             | senha😀😀😀😀     |

  Esquema do Cenário: <id> - <titulo>
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{nome_unico}", "password": <valor> }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"

    Exemplos:
      | id             | titulo      | valor    |
      | CT-API-DOM-044 | Tipo número | 12345678 |
      | CT-API-DOM-045 | Tipo nulo   | null     |

  Esquema do Cenário: <id> - <titulo>
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": <valor> }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"
    Quando envio "PATCH" para "/users/{usuario}/cart/items/{item}" com o corpo:
      """
      { "quantity": <valor> }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"

    Exemplos:
      | id             | titulo           | valor |
      | CT-API-DOM-050 | Texto numérico   | "3"   |
      | CT-API-DOM-051 | Decimal          | 1.5   |
      | CT-API-DOM-052 | Texto com letras | "abc" |
      | CT-API-DOM-053 | Símbolo          | "!"   |
      | CT-API-DOM-054 | Booleano         | true  |
      | CT-API-DOM-055 | Nulo             | null  |
      | CT-API-DOM-056 | Lista            | [1]   |
      | CT-API-DOM-057 | Objeto           | {}    |

  Cenário: CT-API-DOM-058 - Notação científica válida
    Dado que existe um usuário novo
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": 1e1 }
      """
    Então o status da resposta deve ser 201
    E a resposta deve conter:
      """
      { "items": [{ "quantity": 10 }] }
      """

  Cenário: CT-API-DOM-059 - Notação científica acima do limite
    Dado que existe um usuário novo
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": 1e2 }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"

  Esquema do Cenário: <id> - <titulo>
    Dado que existe um usuário novo
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      <corpo>
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"

    Exemplos:
      | id             | titulo                  | corpo                                                                       |
      | CT-API-DOM-060 | companyId em maiúsculas | { "companyId": "PIZZARIA", "productId": "portuguesa", "optionId": "M" }     |
      | CT-API-DOM-061 | productId em maiúsculas | { "companyId": "pizzaria", "productId": "PORTUGUESA", "optionId": "M" }     |
      | CT-API-DOM-062 | optionId em minúscula   | { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "m" }     |
      | CT-API-DOM-063 | Espaço em companyId     | { "companyId": "pizzaria ", "productId": "portuguesa", "optionId": "M" }    |
      | CT-API-DOM-064 | Espaço em optionId      | { "companyId": "pizzaria", "productId": "portuguesa", "optionId": " M" }    |
      | CT-API-DOM-065 | Acento em productId     | { "companyId": "pizzaria", "productId": "portuguêsa", "optionId": "M" }     |
      | CT-API-DOM-066 | Tipo número             | { "companyId": 1, "productId": "portuguesa", "optionId": "M" }              |
      | CT-API-DOM-067 | Tipo nulo               | { "companyId": "pizzaria", "productId": "portuguesa", "optionId": null }    |

  Esquema do Cenário: <id> - <titulo>
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "hamburgueria", "productId": "duplo", "optionId": "U", "replaceCart": <valor> }
      """
    Então a resposta deve ser um erro 409 com o código "CART_COMPANY_CONFLICT"

    Exemplos:
      | id             | titulo                  | valor  |
      | CT-API-DOM-070 | replaceCart como texto  | "true" |
      | CT-API-DOM-071 | replaceCart como número | 1      |
      | CT-API-DOM-072 | replaceCart nulo        | null   |
      | CT-API-DOM-073 | replaceCart falso       | false  |

  Esquema do Cenário: <id> - <titulo>
    Quando envio "GET" para "<caminho>"
    Então a resposta deve ser um erro <status> com o código "<codigo>"

    Exemplos:
      | id             | titulo                      | caminho            | status | codigo           |
      | CT-API-DOM-074 | Acento na URL               | /users/jo%C3%A3o   | 404    | USER_NOT_FOUND   |
      | CT-API-DOM-075 | Espaço na URL               | /users/ana%20maria | 404    | USER_NOT_FOUND   |
      | CT-API-DOM-076 | Codificação inválida na URL | /users/%E0%A4%A    | 400    | VALIDATION_ERROR |
