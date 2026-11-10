# language: pt
@api @regression @feature_usuario
Funcionalidade: Usuários
  Como consumidor da API
  Quero criar e consultar usuários
  Para que clientes possam usar o sistema

  @smoke
  Cenário: CT-API-USR-001 - Criar usuário válido
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{nome_unico}", "password": "senhaValida1" }
      """
    Então o status da resposta deve ser 201
    E a resposta deve conter:
      """
      { "username": "{nome_gerado}" }
      """
    E a resposta deve ter a data de criação
    E a resposta não deve conter dados de senha

  Esquema do Cenário: <id> - <titulo>
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "<nome>", "password": "<senha>" }
      """
    Então o status da resposta deve ser 201

    Exemplos:
      | id             | titulo                   | nome                 | senha        |
      | CT-API-USR-002 | Nome com tamanho mínimo  | {nome_3_caracteres}  | senhaValida1 |
      | CT-API-USR-003 | Nome com tamanho máximo  | {nome_30_caracteres} | senhaValida1 |
      | CT-API-USR-004 | Senha com tamanho mínimo | {nome_unico}         | 12345678     |

  Cenário: CT-API-USR-005 - Nome diferencia maiúsculas
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "Caso_{nome_unico}", "password": "senhaValida1" }
      """
    Então o status da resposta deve ser 201
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "caso_{nome_gerado}", "password": "senhaValida1" }
      """
    Então o status da resposta deve ser 201

  Cenário: CT-API-USR-006 - Nome já existente
    Dado que existe um usuário novo
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{usuario}", "password": "senhaValida1" }
      """
    Então a resposta deve ser um erro 409 com o código "USER_ALREADY_EXISTS"

  Esquema do Cenário: <id> - <titulo>
    Quando envio "POST" para "/users" com o corpo:
      """
      <corpo>
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"

    Exemplos:
      | id             | titulo                 | corpo                                                               |
      | CT-API-USR-007 | Nome abaixo do mínimo  | { "username": "ab", "password": "senhaValida1" }                    |
      | CT-API-USR-008 | Nome acima do máximo   | { "username": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "password": "senhaValida1" } |
      | CT-API-USR-009 | Senha abaixo do mínimo | { "username": "{nome_unico}", "password": "1234567" }               |
      | CT-API-USR-010 | Sem nome               | { "password": "senhaValida1" }                                      |
      | CT-API-USR-011 | Sem senha              | { "username": "{nome_unico}" }                                      |
      | CT-API-USR-013 | JSON malformado        | {"username":                                                        |
      | CT-API-USR-014 | Corpo que não é objeto | []                                                                  |

  Cenário: CT-API-USR-012 - Corpo vazio
    Quando envio "POST" para "/users" sem corpo
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"

  Cenário: CT-API-USR-015 - Corpo acima de 100 KB
    Quando envio "POST" para "/users" com uma senha de 150 KB
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"

  @smoke
  Cenário: CT-API-USR-020 - Consultar usuário existente
    Dado que existe um usuário novo
    Quando envio "GET" para "/users/{usuario}"
    Então o status da resposta deve ser 200
    E a resposta deve conter:
      """
      { "username": "{usuario}" }
      """
    E a resposta deve ter a data de criação
    E a resposta não deve conter dados de senha

  @smoke
  Cenário: CT-API-USR-021 - Usuários pré-cadastrados existem
    Então cada usuário abaixo deve ser encontrado na consulta:
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |

  Cenário: CT-API-USR-022 - Usuário inexistente
    Quando envio "GET" para "/users/{nome_unico}"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

  Cenário: CT-API-USR-023 - Maiúsculas diferentes
    Quando envio "GET" para "/users/User_Manual"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"
