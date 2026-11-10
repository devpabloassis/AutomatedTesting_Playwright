@web @regression @feature_checkout
Feature: Order checkout
  As a customer
  I want to check out my cart
  So that I can move on to payment

  Background:
    Given I am logged in as a new user

  @smoke
  Scenario: TC-WEB-CHK-001 - Check out a valid cart
    Given the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/cart"
    When I check out
    Then I should see the message "Order confirmed"
    And the Pay button should be visible

  # Expected failure: BUG-03. The setup depends on BUG-01.
  @smoke @known_bug
  Scenario: TC-WEB-CHK-002 - Different companies
    Given the user's cart has items from different companies
    And I am on the page "/cart"
    When I check out
    Then I should see the message "The cart has items from different companies. The order cannot be completed."
    And the Pay button should not be visible

  Scenario: TC-WEB-CHK-003 - Update after checking out
    Given the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/cart"
    When I check out
    Then the Pay button should be visible
    When I change the quantity of the item "supreme/M" to "2"
    Then the Pay button should not be visible

  Scenario: TC-WEB-CHK-004 - Remove after checking out
    Given the user's cart has the item "pizzeria/supreme/M"
    And the user's cart has the item "pizzeria/pepperoni/S"
    And I am on the page "/cart"
    When I check out
    Then the Pay button should be visible
    When I remove the item "pepperoni/S"
    Then the Pay button should not be visible

  Scenario: TC-WEB-CHK-005 - Reload after checking out
    Given the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/cart"
    When I check out
    Then the Pay button should be visible
    When I reload the page
    Then the Checkout button should be visible
    And the Pay button should not be visible

  Scenario: TC-WEB-CHK-006 - Pay before checking out
    Given the user's cart has the item "pizzeria/supreme/M"
    When I open the page "/cart"
    Then the Checkout button should be visible
    And the Pay button should not be visible

  Scenario: TC-WEB-CHK-007 - Empty cart
    When I open the page "/cart"
    Then I should see the empty cart notice
    And the Checkout button should not be visible
    And the Pay button should not be visible

  Scenario: TC-WEB-CHK-008 - Cart emptied in another session
    Given the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/cart"
    And the Checkout button should be visible
    When the cart is emptied in another session
    And I check out
    Then I should see the message "The cart is empty."
    And the Pay button should not be visible
