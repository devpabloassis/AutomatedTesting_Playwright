# language: pt
@api @regression @security @sqli
Funcionalidade: SQL injection
  Como responsável pela segurança da API
  Quero garantir que payloads de SQL injection sejam tratados como texto comum
  Para que nenhum dado seja exposto ou alterado

  # Cada esquema roda uma vez para cada um dos 8 payloads da tabela de exemplos.

  Esquema do Cenário: CT-API-SQL-001 [<payload_id>] - Criar usuário com username malicioso
    Dado o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{payload}", "password": "senhaValida1" }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"
    Quando envio "GET" para "/users/{payload}"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-002 [<payload_id>] - Criar usuário com password malicioso
    Dado o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{nome_unico}", "password": "{payload}" }
      """
    Então o status da resposta deve ser 201
    E a resposta não deve conter o payload

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-003 [<payload_id>] - Login com senha igual ao payload
    Dado o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/users" com o corpo:
      """
      { "username": "{nome_unico}", "password": "{payload}" }
      """
    Então o status da resposta deve ser 201
    E o login com as credenciais enviadas deve ter status 200

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  @feature_login
  Esquema do Cenário: CT-API-SQL-004 [<payload_id>] - Login com username malicioso
    Dado o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/login" com o corpo:
      """
      { "username": "{payload}", "password": "loveMetalSongs@" }
      """
    Então a resposta deve ser um erro 401 com o código "INVALID_CREDENTIALS"

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  @feature_login
  Esquema do Cenário: CT-API-SQL-005 [<payload_id>] - Login com password malicioso
    Dado o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/login" com o corpo:
      """
      { "username": "user_manual", "password": "{payload}" }
      """
    Então a resposta deve ser um erro 401 com o código "INVALID_CREDENTIALS"

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-006 [<payload_id>] - Consultar usuário
    Dado o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "GET" para "/users/{payload}"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-007 [<payload_id>] - Consultar empresa
    Dado o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "GET" para "/companies/{payload}"
    Então a resposta deve ser um erro 404 com o código "COMPANY_NOT_FOUND"

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-008 [<payload_id>] - Consultar carrinho
    Dado o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "GET" para "/users/{payload}/cart"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-009 [<payload_id>] - Adicionar item com companyId malicioso
    Dado que existe um usuário novo
    E o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "{payload}", "productId": "portuguesa", "optionId": "M" }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"
    E o carrinho do usuário deve ter 0 itens

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-010 [<payload_id>] - Adicionar item com productId malicioso
    Dado que existe um usuário novo
    E o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "{payload}", "optionId": "M" }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"
    E o carrinho do usuário deve ter 0 itens

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-011 [<payload_id>] - Adicionar item com optionId malicioso
    Dado que existe um usuário novo
    E o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "{payload}" }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"
    E o carrinho do usuário deve ter 0 itens

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-012 [<payload_id>] - Adicionar item com quantity malicioso
    Dado que existe um usuário novo
    E o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": "{payload}" }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"
    E o carrinho do usuário deve ter 0 itens

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-013 [<payload_id>] - Adicionar item com replaceCart malicioso
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/users/{usuario}/cart/items" com o corpo:
      """
      { "companyId": "hamburgueria", "productId": "duplo", "optionId": "U", "replaceCart": "{payload}" }
      """
    Então a resposta deve ser um erro 409 com o código "CART_COMPANY_CONFLICT"
    E o carrinho do usuário deve ter 1 item

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-014 [<payload_id>] - Alterar item com quantity malicioso
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "PATCH" para "/users/{usuario}/cart/items/{item}" com o corpo:
      """
      { "quantity": "{payload}" }
      """
    Então a resposta deve ser um erro 400 com o código "VALIDATION_ERROR"
    E a quantidade do item no carrinho deve ser 1

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-015 [<payload_id>] - Alterar item com itemId malicioso
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "PATCH" para "/users/{usuario}/cart/items/{payload}" com o corpo:
      """
      { "quantity": 2 }
      """
    Então a resposta deve ser um erro 404 com o código "ITEM_NOT_FOUND"
    E a quantidade do item no carrinho deve ser 1

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-016 [<payload_id>] - Excluir item com itemId malicioso
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "DELETE" para "/users/{usuario}/cart/items/{payload}"
    Então a resposta deve ser um erro 404 com o código "ITEM_NOT_FOUND"
    E o carrinho do usuário deve ter 1 item

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  Esquema do Cenário: CT-API-SQL-017 [<payload_id>] - Finalizar e pagar com username malicioso
    Dado o payload de SQL injection:
      """
      <payload>
      """
    Quando envio "POST" para "/users/{payload}/cart/checkout"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"
    Quando envio "POST" para "/users/{payload}/cart/pay"
    Então a resposta deve ser um erro 404 com o código "USER_NOT_FOUND"

    Exemplos:
      | payload_id | payload                                         |
      | SQL-01     | ' OR '1'='1                                     |
      | SQL-02     | ' OR 1=1--                                      |
      | SQL-03     | admin'--                                        |
      | SQL-04     | '; DROP TABLE users;--                          |
      | SQL-05     | " OR ""="                                       |
      | SQL-06     | ' UNION SELECT username, password FROM users--  |
      | SQL-07     | 1; SELECT pg_sleep(5)--                         |
      | SQL-08     | ') OR ('1'='1                                   |

  @smoke
  Cenário: CT-API-SQL-018 - Integridade depois dos ataques
    Então cada usuário abaixo deve ser encontrado na consulta:
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |
    E cada usuário abaixo deve conseguir fazer login com a senha "loveMetalSongs@":
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |
