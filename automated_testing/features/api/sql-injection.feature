@api @regression @security @sqli
Feature: SQL injection
  As the person responsible for API security
  I want SQL injection payloads to be treated as plain text
  So that no data is exposed or changed

  # Each outline runs once for each of the 8 payloads in the examples table.

  Scenario Outline: TC-API-SQL-001 [<payload_id>] - Create user with a malicious username
    Given the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/users" with the body:
      """
      { "username": "{payload}", "password": "validPass1" }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"
    When I send "GET" to "/users/{payload}"
    Then the response should be a 404 error with code "USER_NOT_FOUND"

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-002 [<payload_id>] - Create user with a malicious password
    Given the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/users" with the body:
      """
      { "username": "{unique_name}", "password": "{payload}" }
      """
    Then the response status should be 201
    And the response should not contain the payload

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-003 [<payload_id>] - Log in with the payload as the password
    Given the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/users" with the body:
      """
      { "username": "{unique_name}", "password": "{payload}" }
      """
    Then the response status should be 201
    And logging in with the sent credentials should return status 200

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  @feature_login
  Scenario Outline: TC-API-SQL-004 [<payload_id>] - Log in with a malicious username
    Given the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/login" with the body:
      """
      { "username": "{payload}", "password": "loveMetalSongs@" }
      """
    Then the response should be a 401 error with code "INVALID_CREDENTIALS"

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  @feature_login
  Scenario Outline: TC-API-SQL-005 [<payload_id>] - Log in with a malicious password
    Given the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/login" with the body:
      """
      { "username": "user_manual", "password": "{payload}" }
      """
    Then the response should be a 401 error with code "INVALID_CREDENTIALS"

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-006 [<payload_id>] - Fetch user
    Given the SQL injection payload:
      """
      <payload>
      """
    When I send "GET" to "/users/{payload}"
    Then the response should be a 404 error with code "USER_NOT_FOUND"

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-007 [<payload_id>] - Fetch company
    Given the SQL injection payload:
      """
      <payload>
      """
    When I send "GET" to "/companies/{payload}"
    Then the response should be a 404 error with code "COMPANY_NOT_FOUND"

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-008 [<payload_id>] - Fetch cart
    Given the SQL injection payload:
      """
      <payload>
      """
    When I send "GET" to "/users/{payload}/cart"
    Then the response should be a 404 error with code "USER_NOT_FOUND"

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-009 [<payload_id>] - Add item with a malicious companyId
    Given a new user exists
    And the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "{payload}", "productId": "supreme", "optionId": "M" }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"
    And the user's cart should have 0 items

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-010 [<payload_id>] - Add item with a malicious productId
    Given a new user exists
    And the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "{payload}", "optionId": "M" }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"
    And the user's cart should have 0 items

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-011 [<payload_id>] - Add item with a malicious optionId
    Given a new user exists
    And the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "{payload}" }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"
    And the user's cart should have 0 items

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-012 [<payload_id>] - Add item with a malicious quantity
    Given a new user exists
    And the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M", "quantity": "{payload}" }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"
    And the user's cart should have 0 items

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-013 [<payload_id>] - Add item with a malicious replaceCart
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    And the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "burgers", "productId": "double", "optionId": "R", "replaceCart": "{payload}" }
      """
    Then the response should be a 409 error with code "CART_COMPANY_CONFLICT"
    And the user's cart should have 1 item

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-014 [<payload_id>] - Update item with a malicious quantity
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    And the SQL injection payload:
      """
      <payload>
      """
    When I send "PATCH" to "/users/{user}/cart/items/{item}" with the body:
      """
      { "quantity": "{payload}" }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"
    And the item quantity in the cart should be 1

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-015 [<payload_id>] - Update item with a malicious itemId
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    And the SQL injection payload:
      """
      <payload>
      """
    When I send "PATCH" to "/users/{user}/cart/items/{payload}" with the body:
      """
      { "quantity": 2 }
      """
    Then the response should be a 404 error with code "ITEM_NOT_FOUND"
    And the item quantity in the cart should be 1

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-016 [<payload_id>] - Remove item with a malicious itemId
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    And the SQL injection payload:
      """
      <payload>
      """
    When I send "DELETE" to "/users/{user}/cart/items/{payload}"
    Then the response should be a 404 error with code "ITEM_NOT_FOUND"
    And the user's cart should have 1 item

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  Scenario Outline: TC-API-SQL-017 [<payload_id>] - Check out and pay with a malicious username
    Given the SQL injection payload:
      """
      <payload>
      """
    When I send "POST" to "/users/{payload}/cart/checkout"
    Then the response should be a 404 error with code "USER_NOT_FOUND"
    When I send "POST" to "/users/{payload}/cart/pay"
    Then the response should be a 404 error with code "USER_NOT_FOUND"

    Examples:
      | payload_id | payload                                        |
      | SQL-01     | ' OR '1'='1                                    |
      | SQL-02     | ' OR 1=1--                                     |
      | SQL-03     | admin'--                                       |
      | SQL-04     | '; DROP TABLE users;--                         |
      | SQL-05     | " OR ""="                                      |
      | SQL-06     | ' UNION SELECT username, password FROM users-- |
      | SQL-07     | 1; SELECT pg_sleep(5)--                        |
      | SQL-08     | ') OR ('1'='1                                  |

  @smoke
  Scenario: TC-API-SQL-018 - Integrity after the attacks
    Then each user below should be found:
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |
    And each user below should be able to log in with the password "loveMetalSongs@":
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |
