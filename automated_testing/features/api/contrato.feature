# language: pt
@api @regression @contract
Funcionalidade: Contrato da API
  Como consumidor da API
  Quero que cada resposta siga o contrato documentado
  Para integrar sem depender de campos ou tipos inesperados

  # Os contratos são os JSON Schemas da pasta contracts/, descritos em docs/API_ENDPOINTS.md.
  # Um campo a mais, um campo ausente ou um tipo diferente quebram o contrato.

  # Usuários

  @smoke @feature_usuario
  Cenário: CT-API-CON-001 - Criar usuário
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{nome_unico}", "password": "senhaValida1" }
      """
    Então o status da resposta deve ser 201
    E a resposta deve seguir o contrato "user"

  @feature_usuario
  Cenário: CT-API-CON-002 - Erro de validação ao criar usuário
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "ab", "password": "senhaValida1" }
      """
    Então a resposta deve ser um erro 400 que segue o contrato

  @feature_usuario
  Cenário: CT-API-CON-003 - Usuário já existente
    Dado que existe um usuário novo
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{usuario}", "password": "senhaValida1" }
      """
    Então a resposta deve ser um erro 409 que segue o contrato

  @feature_usuario
  Cenário: CT-API-CON-004 - Consultar usuário
    Dado que existe um usuário novo
    Quando envio "GET" para "/users/{usuario}"
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "user"

  @feature_usuario
  Cenário: CT-API-CON-005 - Usuário inexistente
    Quando envio "GET" para "/users/{nome_unico}"
    Então a resposta deve ser um erro 404 que segue o contrato

  # Login

  @smoke @feature_login
  Cenário: CT-API-CON-006 - Login válido
    Quando envio "POST" para "/login" com o corpo:
      """
      { "username": "user_manual", "password": "loveMetalSongs@" }
      """
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "user"

  @feature_login
  Cenário: CT-API-CON-007 - Login inválido
    Quando envio "POST" para "/login" com o corpo:
      """
      { "username": "user_manual", "password": "senhaErrada" }
      """
    Então a resposta deve ser um erro 401 que segue o contrato

  # Catálogo

  # Falha prevista: BUG-04.
  @smoke @feature_catalogo @known_bug
  Cenário: CT-API-CON-008 - Listar empresas
    Quando envio "GET" para "/companies"
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "companies"

  @feature_catalogo
  Cenário: CT-API-CON-009 - Consultar empresa
    Quando envio "GET" para "/companies/pizzaria"
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "company"

  @feature_catalogo
  Cenário: CT-API-CON-010 - Empresa inexistente
    Quando envio "GET" para "/companies/inexistente"
    Então a resposta deve ser um erro 404 que segue o contrato

  # Carrinho

  @feature_carrinho
  Cenário: CT-API-CON-011 - Carrinho vazio
    Dado que existe um usuário novo
    Quando envio "GET" para "/users/{usuario}/cart"
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "cart"

  @smoke @feature_carrinho
  Cenário: CT-API-CON-012 - Carrinho com itens
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que o carrinho do usuário tem o item "pizzaria/calabresa/G"
    Quando envio "GET" para "/users/{usuario}/cart"
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "cart"

  @feature_carrinho
  Cenário: CT-API-CON-013 - Carrinho de usuário inexistente
    Quando envio "GET" para "/users/{nome_unico}/cart"
    Então a resposta deve ser um erro 404 que segue o contrato

  @feature_carrinho
  Cenário: CT-API-CON-014 - Adicionar item
    Dado que existe um usuário novo
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "sucos", "productId": "laranja", "optionId": "G", "quantity": 2 }
      """
    Então o status da resposta deve ser 201
    E a resposta deve seguir o contrato "cart"

  @feature_carrinho
  Cenário: CT-API-CON-015 - Item inválido
    Dado que existe um usuário novo
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "sucos", "productId": "laranja", "optionId": "U" }
      """
    Então a resposta deve ser um erro 400 que segue o contrato

  @feature_troca_empresa
  Cenário: CT-API-CON-016 - Conflito de empresa
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "hamburgueria", "productId": "duplo", "optionId": "U" }
      """
    Então a resposta deve ser um erro 409 que segue o contrato

  @feature_carrinho
  Cenário: CT-API-CON-017 - Limite de quantidade
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "hamburgueria/duplo/U" com quantidade 99
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "hamburgueria", "productId": "duplo", "optionId": "U" }
      """
    Então a resposta deve ser um erro 422 que segue o contrato

  @feature_carrinho
  Cenário: CT-API-CON-018 - Alterar quantidade
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "PATCH" para "/users/{usuario}/cart/items/{item}" com o corpo:
      """
      { "quantity": 2 }
      """
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "cart"

  @feature_carrinho
  Cenário: CT-API-CON-019 - Alterar item inexistente
    Dado que existe um usuário novo
    Quando envio "PATCH" para "/users/{usuario}/cart/items/inexistente" com o corpo:
      """
      { "quantity": 2 }
      """
    Então a resposta deve ser um erro 404 que segue o contrato

  @feature_carrinho
  Cenário: CT-API-CON-020 - Excluir item
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "DELETE" para "/users/{usuario}/cart/items/{item}"
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "cart"

  @feature_carrinho
  Cenário: CT-API-CON-021 - Excluir item inexistente
    Dado que existe um usuário novo
    Quando envio "DELETE" para "/users/{usuario}/cart/items/inexistente"
    Então a resposta deve ser um erro 404 que segue o contrato

  # Pedido e pagamento

  @smoke @feature_pedido
  Cenário: CT-API-CON-022 - Finalizar pedido
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/checkout"
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "checkout"

  @feature_pedido
  Cenário: CT-API-CON-023 - Finalizar carrinho vazio
    Dado que existe um usuário novo
    Quando envio "POST" para "/users/{usuario}/cart/checkout"
    Então a resposta deve ser um erro 422 que segue o contrato

  @smoke @feature_pagamento
  Cenário: CT-API-CON-024 - Pagar pedido
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando envio "POST" para "/users/{usuario}/cart/pay"
    Então o status da resposta deve ser 200
    E a resposta deve seguir o contrato "payment"

  # A preparação depende do BUG-01.
  @feature_pagamento
  Cenário: CT-API-CON-025 - Pagar com empresas diferentes
    Dado que existe um usuário novo
    E que o carrinho do usuário tem itens de empresas diferentes
    Quando envio "POST" para "/users/{usuario}/cart/pay"
    Então a resposta deve ser um erro 422 que segue o contrato

  # Respostas gerais

  Cenário: CT-API-CON-026 - Rota inexistente
    Quando envio "GET" para "/inexistente"
    Então a resposta deve ser um erro 404 que segue o contrato

  Cenário: CT-API-CON-027 - Método não permitido
    Quando envio "DELETE" para "/users"
    Então a resposta deve ser um erro 405 que segue o contrato

  Cenário: CT-API-CON-028 - JSON inválido
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username":
      """
    Então a resposta deve ser um erro 400 que segue o contrato
