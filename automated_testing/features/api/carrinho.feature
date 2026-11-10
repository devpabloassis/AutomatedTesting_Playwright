# language: pt
@api @regression @feature_carrinho
Funcionalidade: Carrinho
  Como cliente
  Quero consultar, adicionar, alterar e excluir itens do carrinho
  Para montar meu pedido de uma única empresa

  Contexto:
    Dado que existe um usuário novo

  # Consultar

  @smoke
  Cenário: CT-API-CAR-001 - Carrinho vazio
    Quando envio "GET" para "/users/{usuario}/cart"
    Então o status da resposta deve ser 200
    E a resposta deve ser exatamente:
      """
      {
        "username": "{usuario}",
        "items": [],
        "companyIds": [],
        "hasMixedCompanies": false,
        "totalItems": 0,
        "totalCents": 0
      }
      """

  Cenário: CT-API-CAR-002 - Carrinho com itens
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M" com quantidade 2
    Quando envio "GET" para "/users/{usuario}/cart"
    Então o status da resposta deve ser 200
    E a resposta deve conter:
      """
      {
        "items": [{ "productId": "portuguesa", "optionId": "M", "quantity": 2, "subtotalCents": 10580 }],
        "totalItems": 2,
        "totalCents": 10580
      }
      """

  Cenário: CT-API-CAR-003 - Carrinhos independentes
    Dado que existe outro usuário novo com o item "pizzaria/portuguesa/M"
    Quando envio "GET" para "/users/{usuario}/cart"
    Então o status da resposta deve ser 200
    E o carrinho retornado deve ter 0 itens

  Cenário: CT-API-CAR-004 - Usuário inexistente
    Quando envio "GET" para "/users/{nome_unico}/cart"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

  # Adicionar

  @smoke
  Cenário: CT-API-CAR-010 - Adicionar em carrinho vazio
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": 1 }
      """
    Então o status da resposta deve ser 201
    E o carrinho retornado deve ter 1 item
    E a resposta deve conter:
      """
      { "totalCents": 5290 }
      """

  Cenário: CT-API-CAR-011 - Quantidade omitida
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M" }
      """
    Então o status da resposta deve ser 201
    E a resposta deve conter:
      """
      { "items": [{ "quantity": 1 }] }
      """

  Cenário: CT-API-CAR-012 - Outro produto da mesma empresa
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "calabresa", "optionId": "P" }
      """
    Então o status da resposta deve ser 201
    E o carrinho retornado deve ter 2 itens

  Cenário: CT-API-CAR-013 - Mesmo produto e opção
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M" }
      """
    Então o status da resposta deve ser 201
    E a resposta deve conter:
      """
      { "items": [{ "productId": "portuguesa", "quantity": 2 }] }
      """

  Cenário: CT-API-CAR-014 - Mesmo produto, outra opção
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/P"
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "G" }
      """
    Então o status da resposta deve ser 201
    E o carrinho retornado deve ter 2 itens

  Cenário: CT-API-CAR-015 - Quantidade máxima
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": 99 }
      """
    Então o status da resposta deve ser 201
    E a resposta deve conter:
      """
      { "items": [{ "quantity": 99 }] }
      """

  Cenário: CT-API-CAR-016 - Soma até o limite
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M" com quantidade 98
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": 1 }
      """
    Então o status da resposta deve ser 201
    E a resposta deve conter:
      """
      { "items": [{ "quantity": 99 }] }
      """

  Cenário: CT-API-CAR-017 - replaceCart com carrinho vazio
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "replaceCart": true }
      """
    Então o status da resposta deve ser 201
    E o carrinho retornado deve ter 1 item

  Cenário: CT-API-CAR-018 - replaceCart na mesma empresa
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "calabresa", "optionId": "P", "replaceCart": true }
      """
    Então o status da resposta deve ser 201
    E o carrinho retornado deve ter 2 itens

  @smoke @feature_troca_empresa
  Cenário: CT-API-CAR-019 - Outra empresa sem confirmação
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "hamburgueria", "productId": "duplo", "optionId": "U" }
      """
    Então a resposta deve ser um erro 409 com o código "CART_COMPANY_CONFLICT"
    E o carrinho do usuário deve conter somente os produtos "portuguesa"

  # Falha prevista: BUG-01.
  @smoke @feature_troca_empresa @known_bug
  Cenário: CT-API-CAR-020 - Outra empresa com confirmação
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "hamburgueria", "productId": "duplo", "optionId": "U", "replaceCart": true }
      """
    Então o status da resposta deve ser 201
    E o carrinho retornado deve conter somente os produtos "duplo"
    E a resposta deve conter:
      """
      { "hasMixedCompanies": false }
      """

  Cenário: CT-API-CAR-021 - Soma acima do limite
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M" com quantidade 99
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": 1 }
      """
    Então a resposta deve ser um erro 422 com o código "QUANTITY_LIMIT_EXCEEDED"
    E a quantidade do item no carrinho deve ser 99

  Cenário: CT-API-CAR-022 - Usuário inexistente
    Quando envio "POST" para "/users/{nome_unico}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M" }
      """
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

  Esquema do Cenário: <id> - <titulo>
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      <corpo>
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"
    E o carrinho do usuário deve ter 0 itens

    Exemplos:
      | id             | titulo                            | corpo                                                                     |
      | CT-API-CAR-023 | Empresa inexistente               | { "companyId": "x", "productId": "portuguesa", "optionId": "M" }          |
      | CT-API-CAR-024 | Produto inexistente               | { "companyId": "pizzaria", "productId": "x", "optionId": "M" }            |
      | CT-API-CAR-025 | Opção inexistente                 | { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "X" }   |
      | CT-API-CAR-026 | Produto de outra empresa          | { "companyId": "pizzaria", "productId": "duplo", "optionId": "U" }        |
      | CT-API-CAR-027 | Opção U em produto com tamanho    | { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "U" }   |
      | CT-API-CAR-028 | Tamanho em produto de opção única | { "companyId": "hamburgueria", "productId": "duplo", "optionId": "M" }    |
      | CT-API-CAR-029 | Campos obrigatórios ausentes      | {}                                                                        |

  # Alterar quantidade (falhas previstas nos exemplos @known_bug: BUG-02)

  Esquema do Cenário: <id> - <titulo>
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "PATCH" para "/users/{usuario}/cart/items/{item}" com o corpo:
      """
      { "quantity": <quantidade> }
      """
    Então o status da resposta deve ser 200
    E a resposta deve conter:
      """
      { "items": [{ "quantity": <quantidade> }] }
      """

    @smoke @known_bug
    Exemplos:
      | id             | titulo             | quantidade |
      | CT-API-CAR-030 | Alterar quantidade | 3          |

    @known_bug
    Exemplos:
      | id             | titulo            | quantidade |
      | CT-API-CAR-031 | Quantidade mínima | 1          |
      | CT-API-CAR-032 | Quantidade máxima | 99         |

  @known_bug
  Cenário: CT-API-CAR-033 - Recalcular valores
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "PATCH" para "/users/{usuario}/cart/items/{item}" com o corpo:
      """
      { "quantity": 3 }
      """
    Então o status da resposta deve ser 200
    E a resposta deve conter:
      """
      { "items": [{ "subtotalCents": 15870 }], "totalCents": 15870, "totalItems": 3 }
      """

  Esquema do Cenário: <id> - <titulo>
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "PATCH" para "/users/{usuario}/cart/items/{item}" com o corpo:
      """
      <corpo>
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"
    E a quantidade do item no carrinho deve ser 1

    Exemplos:
      | id             | titulo              | corpo             |
      | CT-API-CAR-034 | Quantidade zero     | { "quantity": 0 }   |
      | CT-API-CAR-035 | Acima do máximo     | { "quantity": 100 } |
      | CT-API-CAR-036 | Quantidade negativa | { "quantity": -1 }  |
      | CT-API-CAR-037 | Quantidade ausente  | {}                  |

  Cenário: CT-API-CAR-038 - Item inexistente
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "PATCH" para "/users/{usuario}/cart/items/inexistente" com o corpo:
      """
      { "quantity": 1 }
      """
    Então a resposta deve ser um erro 404 com o código "ITEM_NOT_FOUND"

  Cenário: CT-API-CAR-039 - Usuário inexistente
    Quando envio "PATCH" para "/users/{nome_unico}/cart/items/x" com o corpo:
      """
      { "quantity": 1 }
      """
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

  Cenário: CT-API-CAR-040 - Item de outro usuário
    Dado que existe outro usuário novo com o item "pizzaria/portuguesa/M"
    Quando envio "PATCH" para "/users/{usuario}/cart/items/{item_do_outro}" com o corpo:
      """
      { "quantity": 5 }
      """
    Então a resposta deve ser um erro 404 com o código "ITEM_NOT_FOUND"
    E a quantidade do item do outro usuário deve ser 1

  # Excluir

  @smoke
  Cenário: CT-API-CAR-050 - Excluir um de vários itens
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que o carrinho do usuário tem o item "pizzaria/calabresa/P"
    Quando envio "DELETE" para "/users/{usuario}/cart/items/{item}"
    Então o status da resposta deve ser 200
    E o carrinho retornado deve conter somente os produtos "calabresa"
    E a resposta deve conter:
      """
      { "totalCents": 3490 }
      """

  Cenário: CT-API-CAR-051 - Excluir o último item
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "DELETE" para "/users/{usuario}/cart/items/{item}"
    Então o status da resposta deve ser 200
    E a resposta deve conter:
      """
      { "items": [], "totalCents": 0 }
      """

  Cenário: CT-API-CAR-052 - Item inexistente
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "DELETE" para "/users/{usuario}/cart/items/inexistente"
    Então a resposta deve ser um erro 404 com o código "ITEM_NOT_FOUND"

  Cenário: CT-API-CAR-053 - Item já excluído
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "DELETE" para "/users/{usuario}/cart/items/{item}"
    Então o status da resposta deve ser 200
    Quando envio "DELETE" para "/users/{usuario}/cart/items/{item}"
    Então a resposta deve ser um erro 404 com o código "ITEM_NOT_FOUND"

  Cenário: CT-API-CAR-054 - Usuário inexistente
    Quando envio "DELETE" para "/users/{nome_unico}/cart/items/x"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

  Cenário: CT-API-CAR-055 - Item de outro usuário
    Dado que existe outro usuário novo com o item "pizzaria/portuguesa/M"
    Quando envio "DELETE" para "/users/{usuario}/cart/items/{item_do_outro}"
    Então a resposta deve ser um erro 404 com o código "ITEM_NOT_FOUND"
    E o carrinho do outro usuário deve ter 1 item
