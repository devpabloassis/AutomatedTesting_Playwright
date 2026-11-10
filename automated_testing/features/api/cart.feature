@api @regression @feature_cart
Feature: Cart
  As a customer
  I want to view, add, update and remove cart items
  So that I can build my order from a single company

  Background:
    Given a new user exists

  # View

  @smoke
  Scenario: TC-API-CRT-001 - Empty cart
    When I send "GET" to "/users/{user}/cart"
    Then the response status should be 200
    And the response should be exactly:
      """
      {
        "username": "{user}",
        "items": [],
        "companyIds": [],
        "hasMixedCompanies": false,
        "totalItems": 0,
        "totalCents": 0
      }
      """

  Scenario: TC-API-CRT-002 - Cart with items
    Given the user's cart has the item "pizzeria/supreme/M" with quantity 2
    When I send "GET" to "/users/{user}/cart"
    Then the response status should be 200
    And the response should contain:
      """
      {
        "items": [{ "productId": "supreme", "optionId": "M", "quantity": 2, "subtotalCents": 10580 }],
        "totalItems": 2,
        "totalCents": 10580
      }
      """

  Scenario: TC-API-CRT-003 - Independent carts
    Given another new user exists with the item "pizzeria/supreme/M"
    When I send "GET" to "/users/{user}/cart"
    Then the response status should be 200
    And the returned cart should have 0 items

  Scenario: TC-API-CRT-004 - Non-existent user
    When I send "GET" to "/users/{unique_name}/cart"
    Then the response should be a 404 error with code "USER_NOT_FOUND"

  # Add

  @smoke
  Scenario: TC-API-CRT-010 - Add to an empty cart
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M", "quantity": 1 }
      """
    Then the response status should be 201
    And the returned cart should have 1 item
    And the response should contain:
      """
      { "totalCents": 5290 }
      """

  Scenario: TC-API-CRT-011 - Quantity omitted
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M" }
      """
    Then the response status should be 201
    And the response should contain:
      """
      { "items": [{ "quantity": 1 }] }
      """

  Scenario: TC-API-CRT-012 - Another product from the same company
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "pepperoni", "optionId": "S" }
      """
    Then the response status should be 201
    And the returned cart should have 2 items

  Scenario: TC-API-CRT-013 - Same product and option
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M" }
      """
    Then the response status should be 201
    And the response should contain:
      """
      { "items": [{ "productId": "supreme", "quantity": 2 }] }
      """

  Scenario: TC-API-CRT-014 - Same product, another option
    Given the user's cart has the item "pizzeria/supreme/S"
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "L" }
      """
    Then the response status should be 201
    And the returned cart should have 2 items

  Scenario: TC-API-CRT-015 - Maximum quantity
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M", "quantity": 99 }
      """
    Then the response status should be 201
    And the response should contain:
      """
      { "items": [{ "quantity": 99 }] }
      """

  Scenario: TC-API-CRT-016 - Sum up to the limit
    Given the user's cart has the item "pizzeria/supreme/M" with quantity 98
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M", "quantity": 1 }
      """
    Then the response status should be 201
    And the response should contain:
      """
      { "items": [{ "quantity": 99 }] }
      """

  Scenario: TC-API-CRT-017 - replaceCart with an empty cart
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M", "replaceCart": true }
      """
    Then the response status should be 201
    And the returned cart should have 1 item

  Scenario: TC-API-CRT-018 - replaceCart with the same company
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "pepperoni", "optionId": "S", "replaceCart": true }
      """
    Then the response status should be 201
    And the returned cart should have 2 items

  @smoke @feature_company_switch
  Scenario: TC-API-CRT-019 - Another company without confirmation
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "burgers", "productId": "double", "optionId": "R" }
      """
    Then the response should be a 409 error with code "CART_COMPANY_CONFLICT"
    And the user's cart should contain only the products "supreme"

  # Expected failure: BUG-01.
  @smoke @feature_company_switch @known_bug
  Scenario: TC-API-CRT-020 - Another company with confirmation
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "burgers", "productId": "double", "optionId": "R", "replaceCart": true }
      """
    Then the response status should be 201
    And the returned cart should contain only the products "double"
    And the response should contain:
      """
      { "hasMixedCompanies": false }
      """

  Scenario: TC-API-CRT-021 - Sum above the limit
    Given the user's cart has the item "pizzeria/supreme/M" with quantity 99
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M", "quantity": 1 }
      """
    Then the response should be a 422 error with code "QUANTITY_LIMIT_EXCEEDED"
    And the item quantity in the cart should be 99

  Scenario: TC-API-CRT-022 - Non-existent user
    When I send "POST" to "/users/{unique_name}/cart/items" with the body:
      """
      { "companyId": "pizzeria", "productId": "supreme", "optionId": "M" }
      """
    Then the response should be a 404 error with code "USER_NOT_FOUND"

  Scenario Outline: <id> - <title>
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      <body>
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"
    And the user's cart should have 0 items

    Examples:
      | id             | title                           | body                                                                 |
      | TC-API-CRT-023 | Non-existent company            | { "companyId": "x", "productId": "supreme", "optionId": "M" }        |
      | TC-API-CRT-024 | Non-existent product            | { "companyId": "pizzeria", "productId": "x", "optionId": "M" }       |
      | TC-API-CRT-025 | Non-existent option             | { "companyId": "pizzeria", "productId": "supreme", "optionId": "X" } |
      | TC-API-CRT-026 | Product from another company    | { "companyId": "pizzeria", "productId": "double", "optionId": "R" }  |
      | TC-API-CRT-027 | Option R on a sized product     | { "companyId": "pizzeria", "productId": "supreme", "optionId": "R" } |
      | TC-API-CRT-028 | Size on a single-option product | { "companyId": "burgers", "productId": "double", "optionId": "M" }   |
      | TC-API-CRT-029 | Missing required fields         | {}                                                                   |

  # Update quantity (expected failures in the @known_bug examples: BUG-02)

  Scenario Outline: <id> - <title>
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "PATCH" to "/users/{user}/cart/items/{item}" with the body:
      """
      { "quantity": <quantity> }
      """
    Then the response status should be 200
    And the response should contain:
      """
      { "items": [{ "quantity": <quantity> }] }
      """

    @smoke @known_bug
    Examples:
      | id             | title           | quantity |
      | TC-API-CRT-030 | Update quantity | 3        |

    @known_bug
    Examples:
      | id             | title            | quantity |
      | TC-API-CRT-031 | Minimum quantity | 1        |
      | TC-API-CRT-032 | Maximum quantity | 99       |

  @known_bug
  Scenario: TC-API-CRT-033 - Recalculate amounts
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "PATCH" to "/users/{user}/cart/items/{item}" with the body:
      """
      { "quantity": 3 }
      """
    Then the response status should be 200
    And the response should contain:
      """
      { "items": [{ "subtotalCents": 15870 }], "totalCents": 15870, "totalItems": 3 }
      """

  Scenario Outline: <id> - <title>
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "PATCH" to "/users/{user}/cart/items/{item}" with the body:
      """
      <body>
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"
    And the item quantity in the cart should be 1

    Examples:
      | id             | title             | body                |
      | TC-API-CRT-034 | Zero quantity     | { "quantity": 0 }   |
      | TC-API-CRT-035 | Above the maximum | { "quantity": 100 } |
      | TC-API-CRT-036 | Negative quantity | { "quantity": -1 }  |
      | TC-API-CRT-037 | Missing quantity  | {}                  |

  Scenario: TC-API-CRT-038 - Non-existent item
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "PATCH" to "/users/{user}/cart/items/nonexistent" with the body:
      """
      { "quantity": 1 }
      """
    Then the response should be a 404 error with code "ITEM_NOT_FOUND"

  Scenario: TC-API-CRT-039 - Non-existent user
    When I send "PATCH" to "/users/{unique_name}/cart/items/x" with the body:
      """
      { "quantity": 1 }
      """
    Then the response should be a 404 error with code "USER_NOT_FOUND"

  Scenario: TC-API-CRT-040 - Another user's item
    Given another new user exists with the item "pizzeria/supreme/M"
    When I send "PATCH" to "/users/{user}/cart/items/{other_item}" with the body:
      """
      { "quantity": 5 }
      """
    Then the response should be a 404 error with code "ITEM_NOT_FOUND"
    And the other user's item quantity should be 1

  # Remove

  @smoke
  Scenario: TC-API-CRT-050 - Remove one of several items
    Given the user's cart has the item "pizzeria/supreme/M"
    And the user's cart has the item "pizzeria/pepperoni/S"
    When I send "DELETE" to "/users/{user}/cart/items/{item}"
    Then the response status should be 200
    And the returned cart should contain only the products "pepperoni"
    And the response should contain:
      """
      { "totalCents": 3490 }
      """

  Scenario: TC-API-CRT-051 - Remove the last item
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "DELETE" to "/users/{user}/cart/items/{item}"
    Then the response status should be 200
    And the response should contain:
      """
      { "items": [], "totalCents": 0 }
      """

  Scenario: TC-API-CRT-052 - Non-existent item
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "DELETE" to "/users/{user}/cart/items/nonexistent"
    Then the response should be a 404 error with code "ITEM_NOT_FOUND"

  Scenario: TC-API-CRT-053 - Item already removed
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "DELETE" to "/users/{user}/cart/items/{item}"
    Then the response status should be 200
    When I send "DELETE" to "/users/{user}/cart/items/{item}"
    Then the response should be a 404 error with code "ITEM_NOT_FOUND"

  Scenario: TC-API-CRT-054 - Non-existent user
    When I send "DELETE" to "/users/{unique_name}/cart/items/x"
    Then the response should be a 404 error with code "USER_NOT_FOUND"

  Scenario: TC-API-CRT-055 - Another user's item
    Given another new user exists with the item "pizzeria/supreme/M"
    When I send "DELETE" to "/users/{user}/cart/items/{other_item}"
    Then the response should be a 404 error with code "ITEM_NOT_FOUND"
    And the other user's cart should have 1 item
