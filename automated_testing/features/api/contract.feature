@api @regression @contract
Feature: API contract
  As an API consumer
  I want every response to follow the documented contract
  So that I can integrate without relying on unexpected fields or types

  # The contracts are the JSON Schemas in contracts/, described in docs/API_ENDPOINTS.md.
  # An extra field, a missing field or a different type breaks the contract.

  # Users

  @smoke @feature_user
  Scenario: TC-API-CON-001 - Create user
    When I send "POST" to "/users" with the body:
      """
      { "username": "{unique_name}", "password": "validPass1" }
      """
    Then the response status should be 201
    And the response should follow the "user" contract

  @feature_user
  Scenario: TC-API-CON-002 - Validation error when creating a user
    When I send "POST" to "/users" with the body:
      """
      { "username": "ab", "password": "validPass1" }
      """
    Then the response should be a 400 error that follows the contract

  @feature_user
  Scenario: TC-API-CON-003 - User already exists
    Given a new user exists
    When I send "POST" to "/users" with the body:
      """
      { "username": "{user}", "password": "validPass1" }
      """
    Then the response should be a 409 error that follows the contract

  @feature_user
  Scenario: TC-API-CON-004 - Fetch user
    Given a new user exists
    When I send "GET" to "/users/{user}"
    Then the response status should be 200
    And the response should follow the "user" contract

  @feature_user
  Scenario: TC-API-CON-005 - Non-existent user
    When I send "GET" to "/users/{unique_name}"
    Then the response should be a 404 error that follows the contract

  # Login

  @smoke @feature_login
  Scenario: TC-API-CON-006 - Valid login
    When I send "POST" to "/login" with the body:
      """
      { "username": "user_manual", "password": "loveMetalSongs@" }
      """
    Then the response status should be 200
    And the response should follow the "user" contract

  @feature_login
  Scenario: TC-API-CON-007 - Invalid login
    When I send "POST" to "/login" with the body:
      """
      { "username": "user_manual", "password": "wrongPass" }
      """
    Then the response should be a 401 error that follows the contract

  # Catalog

  # Expected failure: BUG-04.
  @smoke @feature_catalog @known_bug
  Scenario: TC-API-CON-008 - List companies
    When I send "GET" to "/companies"
    Then the response status should be 200
    And the response should follow the "companies" contract

  @feature_catalog
  Scenario: TC-API-CON-009 - Fetch company
    When I send "GET" to "/companies/pizzeria"
    Then the response status should be 200
    And the response should follow the "company" contract

  @feature_catalog
  Scenario: TC-API-CON-010 - Non-existent company
    When I send "GET" to "/companies/nonexistent"
    Then the response should be a 404 error that follows the contract

  # Cart

  @feature_cart
  Scenario: TC-API-CON-011 - Empty cart
    Given a new user exists
    When I send "GET" to "/users/{user}/cart"
    Then the response status should be 200
    And the response should follow the "cart" contract

  @smoke @feature_cart
  Scenario: TC-API-CON-012 - Cart with items
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    And the user's cart has the item "pizzeria/pepperoni/L"
    When I send "GET" to "/users/{user}/cart"
    Then the response status should be 200
    And the response should follow the "cart" contract

  @feature_cart
  Scenario: TC-API-CON-013 - Cart of a non-existent user
    When I send "GET" to "/users/{unique_name}/cart"
    Then the response should be a 404 error that follows the contract

  @feature_cart
  Scenario: TC-API-CON-014 - Add item
    Given a new user exists
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "juices", "productId": "orange", "optionId": "L", "quantity": 2 }
      """
    Then the response status should be 201
    And the response should follow the "cart" contract

  @feature_cart
  Scenario: TC-API-CON-015 - Invalid item
    Given a new user exists
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "juices", "productId": "orange", "optionId": "R" }
      """
    Then the response should be a 400 error that follows the contract

  @feature_company_switch
  Scenario: TC-API-CON-016 - Company conflict
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "burgers", "productId": "double", "optionId": "R" }
      """
    Then the response should be a 409 error that follows the contract

  @feature_cart
  Scenario: TC-API-CON-017 - Quantity limit
    Given a new user exists
    And the user's cart has the item "burgers/double/R" with quantity 99
    When I send "POST" to "/users/{user}/cart/items" with the body:
      """
      { "companyId": "burgers", "productId": "double", "optionId": "R" }
      """
    Then the response should be a 422 error that follows the contract

  @feature_cart
  Scenario: TC-API-CON-018 - Update quantity
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    When I send "PATCH" to "/users/{user}/cart/items/{item}" with the body:
      """
      { "quantity": 2 }
      """
    Then the response status should be 200
    And the response should follow the "cart" contract

  @feature_cart
  Scenario: TC-API-CON-019 - Update a non-existent item
    Given a new user exists
    When I send "PATCH" to "/users/{user}/cart/items/nonexistent" with the body:
      """
      { "quantity": 2 }
      """
    Then the response should be a 404 error that follows the contract

  @feature_cart
  Scenario: TC-API-CON-020 - Remove item
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    When I send "DELETE" to "/users/{user}/cart/items/{item}"
    Then the response status should be 200
    And the response should follow the "cart" contract

  @feature_cart
  Scenario: TC-API-CON-021 - Remove a non-existent item
    Given a new user exists
    When I send "DELETE" to "/users/{user}/cart/items/nonexistent"
    Then the response should be a 404 error that follows the contract

  # Checkout and payment

  @smoke @feature_checkout
  Scenario: TC-API-CON-022 - Check out
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/checkout"
    Then the response status should be 200
    And the response should follow the "checkout" contract

  @feature_checkout
  Scenario: TC-API-CON-023 - Check out an empty cart
    Given a new user exists
    When I send "POST" to "/users/{user}/cart/checkout"
    Then the response should be a 422 error that follows the contract

  @smoke @feature_payment
  Scenario: TC-API-CON-024 - Pay for the order
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/pay"
    Then the response status should be 200
    And the response should follow the "payment" contract

  # The setup depends on BUG-01.
  @feature_payment
  Scenario: TC-API-CON-025 - Pay with different companies
    Given a new user exists
    And the user's cart has items from different companies
    When I send "POST" to "/users/{user}/cart/pay"
    Then the response should be a 422 error that follows the contract

  # General responses

  Scenario: TC-API-CON-026 - Non-existent route
    When I send "GET" to "/nonexistent"
    Then the response should be a 404 error that follows the contract

  Scenario: TC-API-CON-027 - Method not allowed
    When I send "DELETE" to "/users"
    Then the response should be a 405 error that follows the contract

  Scenario: TC-API-CON-028 - Invalid JSON
    When I send "POST" to "/users" with the body:
      """
      { "username":
      """
    Then the response should be a 400 error that follows the contract
