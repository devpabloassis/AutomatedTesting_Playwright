# language: pt
@api @regression
Funcionalidade: Finalização e pagamento do pedido
  Como cliente
  Quero finalizar e pagar o pedido
  Para concluir a compra de uma única empresa

  Contexto:
    Dado que existe um usuário novo

  # Finalização

  @smoke @feature_pedido
  Cenário: CT-API-PED-001 - Finalizar carrinho válido
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/checkout"
    Então o status da resposta deve ser 200
    E a resposta deve ser exatamente:
      """
      { "status": "READY_FOR_PAYMENT", "totalCents": 5290 }
      """
    E o carrinho do usuário deve ter 1 item

  @feature_pedido
  Cenário: CT-API-PED-002 - Finalizar carrinho vazio
    Quando envio "POST" para "/users/{usuario}/cart/checkout"
    Então a resposta deve ser um erro 422 com o código "CART_EMPTY"

  # Falha prevista: BUG-03. A preparação depende do BUG-01.
  @smoke @feature_pedido @known_bug
  Cenário: CT-API-PED-003 - Finalizar com empresas diferentes
    Dado que o carrinho do usuário tem itens de empresas diferentes
    Quando envio "POST" para "/users/{usuario}/cart/checkout"
    Então a resposta deve ser um erro 422 com o código "CART_MIXED_COMPANIES"
    E a mensagem de erro deve ser "Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido."

  @feature_pedido
  Cenário: CT-API-PED-004 - Finalizar duas vezes
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/checkout"
    Então o status da resposta deve ser 200
    Quando envio "POST" para "/users/{usuario}/cart/checkout"
    Então o status da resposta deve ser 200

  @feature_pedido
  Cenário: CT-API-PED-005 - Finalizar com usuário inexistente
    Quando envio "POST" para "/users/{nome_unico}/cart/checkout"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

  # Pagamento

  @smoke @feature_pagamento
  Cenário: CT-API-PED-010 - Pagar carrinho válido
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/checkout"
    Então o status da resposta deve ser 200
    Quando envio "POST" para "/users/{usuario}/cart/pay"
    Então o status da resposta deve ser 200
    E a resposta deve conter:
      """
      { "status": "PAID", "message": "Pagamento Fake efetuado" }
      """
    E o carrinho do usuário deve ter 0 itens

  @feature_pagamento
  Cenário: CT-API-PED-011 - Pagar sem finalizar antes
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/pay"
    Então o status da resposta deve ser 200
    E a resposta deve conter:
      """
      { "status": "PAID" }
      """

  @feature_pagamento
  Cenário: CT-API-PED-012 - Pagar carrinho vazio
    Quando envio "POST" para "/users/{usuario}/cart/pay"
    Então a resposta deve ser um erro 422 com o código "CART_EMPTY"

  # A preparação depende do BUG-01.
  @feature_pagamento
  Cenário: CT-API-PED-013 - Pagar com empresas diferentes
    Dado que o carrinho do usuário tem itens de empresas diferentes
    Quando envio "POST" para "/users/{usuario}/cart/pay"
    Então a resposta deve ser um erro 422 com o código "CART_MIXED_COMPANIES"
    E o carrinho do usuário deve ter 2 itens

  @feature_pagamento
  Cenário: CT-API-PED-014 - Pagar duas vezes
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/pay"
    Então o status da resposta deve ser 200
    Quando envio "POST" para "/users/{usuario}/cart/pay"
    Então a resposta deve ser um erro 422 com o código "CART_EMPTY"

  @feature_pagamento
  Cenário: CT-API-PED-015 - Pagar com usuário inexistente
    Quando envio "POST" para "/users/{nome_unico}/cart/pay"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"
