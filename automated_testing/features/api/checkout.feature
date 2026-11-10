@api @regression
Feature: Order checkout and payment
  As a customer
  I want to check out and pay for my order
  So that I complete a purchase from a single company

  Background:
    Given a new user exists

  # Checkout

  @smoke @feature_checkout
  Scenario: TC-API-ORD-001 - Check out a valid cart
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/checkout"
    Then the response status should be 200
    And the response should be exactly:
      """
      { "status": "READY_FOR_PAYMENT", "totalCents": 5290 }
      """
    And the user's cart should have 1 item

  @feature_checkout
  Scenario: TC-API-ORD-002 - Check out an empty cart
    When I send "POST" to "/users/{user}/cart/checkout"
    Then the response should be a 422 error with code "CART_EMPTY"

  # Expected failure: BUG-03. The setup depends on BUG-01.
  @smoke @feature_checkout @known_bug
  Scenario: TC-API-ORD-003 - Check out with different companies
    Given the user's cart has items from different companies
    When I send "POST" to "/users/{user}/cart/checkout"
    Then the response should be a 422 error with code "CART_MIXED_COMPANIES"
    And the error message should be "The cart has items from different companies. The order cannot be completed."

  @feature_checkout
  Scenario: TC-API-ORD-004 - Check out twice
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/checkout"
    Then the response status should be 200
    When I send "POST" to "/users/{user}/cart/checkout"
    Then the response status should be 200

  @feature_checkout
  Scenario: TC-API-ORD-005 - Check out with a non-existent user
    When I send "POST" to "/users/{unique_name}/cart/checkout"
    Then the response should be a 404 error with code "USER_NOT_FOUND"

  # Payment

  @smoke @feature_payment
  Scenario: TC-API-ORD-010 - Pay for a valid cart
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/checkout"
    Then the response status should be 200
    When I send "POST" to "/users/{user}/cart/pay"
    Then the response status should be 200
    And the response should contain:
      """
      { "status": "PAID", "message": "Fake payment completed" }
      """
    And the user's cart should have 0 items

  @feature_payment
  Scenario: TC-API-ORD-011 - Pay without checking out first
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/pay"
    Then the response status should be 200
    And the response should contain:
      """
      { "status": "PAID" }
      """

  @feature_payment
  Scenario: TC-API-ORD-012 - Pay for an empty cart
    When I send "POST" to "/users/{user}/cart/pay"
    Then the response should be a 422 error with code "CART_EMPTY"

  # The setup depends on BUG-01.
  @feature_payment
  Scenario: TC-API-ORD-013 - Pay with different companies
    Given the user's cart has items from different companies
    When I send "POST" to "/users/{user}/cart/pay"
    Then the response should be a 422 error with code "CART_MIXED_COMPANIES"
    And the user's cart should have 2 items

  @feature_payment
  Scenario: TC-API-ORD-014 - Pay twice
    Given the user's cart has the item "pizzeria/supreme/M"
    When I send "POST" to "/users/{user}/cart/pay"
    Then the response status should be 200
    When I send "POST" to "/users/{user}/cart/pay"
    Then the response should be a 422 error with code "CART_EMPTY"

  @feature_payment
  Scenario: TC-API-ORD-015 - Pay with a non-existent user
    When I send "POST" to "/users/{unique_name}/cart/pay"
    Then the response should be a 404 error with code "USER_NOT_FOUND"
