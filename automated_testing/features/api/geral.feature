# language: pt
@api @regression
Funcionalidade: Requisições e persistência
  Como responsável pela API
  Quero respostas consistentes e dados gravados com segurança
  Para que o sistema se comporte bem entre reinícios

  @smoke
  Cenário: CT-API-GER-001 - Resposta em JSON
    Quando envio "GET" para "/companies"
    Então o cabeçalho "content-type" da resposta deve conter "application/json"

  Cenário: CT-API-GER-002 - Rota inexistente
    Quando envio "GET" para "/inexistente"
    Então a resposta deve ser um erro 404 com o código "NOT_FOUND"

  Cenário: CT-API-GER-003 - Método não permitido
    Quando envio "DELETE" para "/users"
    Então a resposta deve ser um erro 405 com o código "METHOD_NOT_ALLOWED"

  # Os cenários abaixo reiniciam o sistema, por isso usam servidor e banco próprios.

  @persistence
  Cenário: CT-API-GER-010 - Dados mantidos ao reiniciar
    Dado que estou usando um servidor isolado
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{nome_unico}", "password": "senhaValida1" }
      """
    E envio "POST" para "/users/{nome_gerado}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M" }
      """
    E reinicio o servidor
    E envio "POST" para "/login" com o corpo:
      """
      { "username": "{nome_gerado}", "password": "senhaValida1" }
      """
    Então o status da resposta deve ser 200
    Quando envio "GET" para "/users/{nome_gerado}/cart"
    Então o carrinho retornado deve conter somente os produtos "portuguesa"

  @persistence
  Cenário: CT-API-GER-011 - Reinício não duplica nem altera pré-cadastrados
    Dado que estou usando um servidor isolado
    E que guardo a data de criação dos usuários pré-cadastrados
    Quando reinicio o servidor
    Então a data de criação dos usuários pré-cadastrados deve ser a mesma
    E cada usuário pré-cadastrado deve aparecer uma única vez no banco

  @security @persistence
  Cenário: CT-API-GER-012 - Senha não gravada em texto puro
    Dado que estou usando um servidor isolado
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{nome_unico}", "password": "{senha_unica}" }
      """
    Então o status da resposta deve ser 201
    E o arquivo do banco não deve conter a senha enviada
