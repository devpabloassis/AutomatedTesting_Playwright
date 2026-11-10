@api @regression @domain
Feature: Field domain characters
  As the API owner
  I want to accept only values inside each field's domain
  So that invalid input is rejected before it is processed

  # The {unique_...} placeholders generate new values from the same character class,
  # so the scenario can run again against the same database.
  Scenario Outline: <id> - <title>
    When I send "POST" to "/users" with the body:
      """
      { "username": "<username>", "password": "validPass1" }
      """
    Then the response status should be 201

    Examples:
      | id             | title             | username           |
      | TC-API-DOM-001 | Lowercase only    | {unique_lowercase} |
      | TC-API-DOM-002 | Uppercase only    | {unique_uppercase} |
      | TC-API-DOM-003 | Digits only       | {unique_digits}    |
      | TC-API-DOM-004 | Underscores only  | {free_underscores} |
      | TC-API-DOM-005 | Valid combination | {unique_mix}       |

  # Values are written as JSON. In the table, \\ represents a single backslash.
  Scenario Outline: <id> - <title>
    When I send "POST" to "/users" with the body:
      """
      { "username": <value>, "password": "validPass1" }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"

    Examples:
      | id             | title               | value           |
      | TC-API-DOM-010 | Empty string        | ""              |
      | TC-API-DOM-011 | Inner space         | "john doe"      |
      | TC-API-DOM-012 | Leading space       | " johndoe"      |
      | TC-API-DOM-013 | Trailing space      | "johndoe "      |
      | TC-API-DOM-014 | Trailing line break | "johndoe\\n"    |
      | TC-API-DOM-015 | Tab                 | "john\\tdoe"    |
      | TC-API-DOM-016 | Hyphen              | "john-doe"      |
      | TC-API-DOM-017 | Dot                 | "john.doe"      |
      | TC-API-DOM-018 | At sign             | "john@doe"      |
      | TC-API-DOM-019 | Accented letter     | "joão"          |
      | TC-API-DOM-020 | Cedilla             | "façade"        |
      | TC-API-DOM-021 | Emoji               | "john😀"        |
      | TC-API-DOM-022 | Single quote        | "john'doe"      |
      | TC-API-DOM-023 | Double quote        | "john\"doe"     |
      | TC-API-DOM-024 | Semicolon           | "john;doe"      |
      | TC-API-DOM-025 | Percent sign        | "john%doe"      |
      | TC-API-DOM-026 | Slashes             | "john/doe\\\\x" |
      | TC-API-DOM-027 | HTML markup         | "<b>john</b>"   |
      | TC-API-DOM-028 | Number type         | 123456          |
      | TC-API-DOM-029 | Null type           | null            |
      | TC-API-DOM-030 | Array type          | ["john_doe"]    |

  Scenario Outline: <id> - <title>
    When I send "POST" to "/users" with the body:
      """
      { "username": "{unique_name}", "password": "<password>" }
      """
    Then the response status should be 201
    And logging in with the sent credentials should return status 200

    Examples:
      | id             | title               | password             |
      | TC-API-DOM-040 | Symbols             | !@#$%^&*()           |
      | TC-API-DOM-041 | Accents and cedilla | açãoÉótima           |
      | TC-API-DOM-042 | Spaces              | password with spaces |
      | TC-API-DOM-043 | Emoji               | secret😀😀😀😀       |

  Scenario Outline: <id> - <title>
    When I send "POST" to "/users" with the body:
      """
      { "username": "{unique_name}", "password": <value> }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"

    Examples:
      | id             | title       | value    |
      | TC-API-DOM-044 | Number type | 12345678 |
      | TC-API-DOM-045 | Null type   | null     |

  Scenario Outline: <id> - <title>
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M", "quantity": <value> }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"
    When I send "PATCH" to "/users/{user}/cart/items/{item}" with the body:
      """
      { "quantity": <value> }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"

    Examples:
      | id             | title             | value |
      | TC-API-DOM-050 | Numeric string    | "3"   |
      | TC-API-DOM-051 | Decimal           | 1.5   |
      | TC-API-DOM-052 | Alphabetic string | "abc" |
      | TC-API-DOM-053 | Symbol            | "!"   |
      | TC-API-DOM-054 | Boolean           | true  |
      | TC-API-DOM-055 | Null              | null  |
      | TC-API-DOM-056 | Array             | [1]   |
      | TC-API-DOM-057 | Object            | {}    |

  Scenario: TC-API-DOM-058 - Valid scientific notation
    Given a new user exists
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M", "quantity": 1e1 }
      """
    Then the response status should be 201
    And the response should contain:
      """
      { "items": [{ "quantity": 10 }] }
      """

  Scenario: TC-API-DOM-059 - Scientific notation above the limit
    Given a new user exists
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M", "quantity": 1e2 }
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"

  Scenario Outline: <id> - <title>
    Given a new user exists
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      <body>
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"

    Examples:
      | id             | title               | body                                                                  |
      | TC-API-DOM-060 | Uppercase companyId | { "companyId": "PIZZERIA", "productId": "supreme", "optionId": "M" }  |
      | TC-API-DOM-061 | Uppercase productId | { "companyId": "pizzeria", "productId": "SUPREME", "optionId": "M" }  |
      | TC-API-DOM-062 | Lowercase optionId  | { "companyId": "pizzeria", "productId": "supreme", "optionId": "m" }  |
      | TC-API-DOM-063 | Space in companyId  | { "companyId": "pizzeria ", "productId": "supreme", "optionId": "M" } |
      | TC-API-DOM-064 | Space in optionId   | { "companyId": "pizzeria", "productId": "supreme", "optionId": " M" } |
      | TC-API-DOM-065 | Accent in productId | { "companyId": "pizzeria", "productId": "suprême", "optionId": "M" }  |
      | TC-API-DOM-066 | Number type         | { "companyId": 1, "productId": "supreme", "optionId": "M" }           |
      | TC-API-DOM-067 | Null type           | { "companyId": "pizzeria", "productId": "supreme", "optionId": null } |

  Scenario Outline: <id> - <title>
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "burgers", "productId": "double", "optionId": "R", "replaceCart": <value> }
      """
    Then the response should be a 409 error with code "CART_COMPANY_CONFLICT"

    Examples:
      | id             | title                 | value  |
      | TC-API-DOM-070 | replaceCart as string | "true" |
      | TC-API-DOM-071 | replaceCart as number | 1      |
      | TC-API-DOM-072 | replaceCart null      | null   |
      | TC-API-DOM-073 | replaceCart false     | false  |

  Scenario Outline: <id> - <title>
    When I send "GET" to "<path>"
    Then the response should be a <status> error with code "<code>"

    Examples:
      | id             | title                | path              | status | code             |
      | TC-API-DOM-074 | Accent in the URL    | /users/jo%C3%A3o  | 404    | USER_NOT_FOUND   |
      | TC-API-DOM-075 | Space in the URL     | /users/john%20doe | 404    | USER_NOT_FOUND   |
      | TC-API-DOM-076 | Invalid URL encoding | /users/%E0%A4%A   | 400    | VALIDATION_ERROR |
