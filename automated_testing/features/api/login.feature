# language: pt
@api @regression @feature_login
Funcionalidade: Login
  Como consumidor da API
  Quero validar usuário e senha
  Para conceder acesso somente a credenciais corretas

  @smoke
  Cenário: CT-API-LOG-001 - Credenciais válidas
    Dado que existe um usuário novo
    Quando envio "POST" para "/login" com o corpo:
      """
      { "username": "{usuario}", "password": "senhaValida1" }
      """
    Então o status da resposta deve ser 200
    E a resposta deve conter:
      """
      { "username": "{usuario}" }
      """
    E a resposta não deve conter dados de senha

  @smoke
  Cenário: CT-API-LOG-002 - Login dos pré-cadastrados
    Então cada usuário abaixo deve conseguir fazer login com a senha "loveMetalSongs@":
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |

  Esquema do Cenário: <id> - <titulo>
    Quando envio "POST" para "/login" com o corpo:
      """
      { "username": "<usuario>", "password": "<senha>" }
      """
    Então a resposta deve ser um erro 401 com o código "INVALID_CREDENTIALS"
    E a mensagem de erro deve ser "Usuário ou senha inválidos."

    Exemplos:
      | id             | titulo                          | usuario      | senha           |
      | CT-API-LOG-003 | Senha incorreta                 | user_manual  | senhaErrada1    |
      | CT-API-LOG-004 | Usuário inexistente             | {nome_unico} | loveMetalSongs@ |
      | CT-API-LOG-005 | Senha com maiúsculas diferentes | user_manual  | LOVEMETALSONGS@ |

  Esquema do Cenário: <id> - <titulo>
    Quando envio "POST" para "/login" com o corpo:
      """
      <corpo>
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"

    Exemplos:
      | id             | titulo                   | corpo                                  |
      | CT-API-LOG-006 | Sem usuário              | { "password": "loveMetalSongs@" }      |
      | CT-API-LOG-007 | Sem senha                | { "username": "user_manual" }          |
      | CT-API-LOG-008 | Campos que não são texto | { "username": 123, "password": 123 }   |
