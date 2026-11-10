@web @regression @feature_payment
Feature: Payment
  As a customer
  I want to pay for my checked-out order
  So that I complete the purchase

  Background:
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/cart"
    And I check out
    And the Pay button should be visible

  @smoke
  Scenario: TC-WEB-PAY-001 - Pay for the order
    When I click Pay
    Then I should see the message "Fake payment completed"

  @smoke
  Scenario: TC-WEB-PAY-002 - Cart after payment
    When I click Pay
    Then I should see the empty cart notice
    And the cart counter should show "0"

  Scenario: TC-WEB-PAY-003 - Cart emptied before paying
    When the cart is emptied in another session
    And I click Pay
    Then I should see the message "The cart is empty."
    And the Pay button should not be visible

  Scenario: TC-WEB-PAY-004 - API failure when paying
    Given the API responds with a 500 error on "**/cart/pay"
    When I click Pay
    Then I should see the message "Internal error."
    And the message "Fake payment completed" should not appear

  # The setup depends on BUG-01.
  Scenario: TC-WEB-PAY-005 - Pay with different companies
    When the cart receives the item "burgers/double/R" with a company switch in another session
    And I click Pay
    Then I should see the message "The cart has items from different companies. The order cannot be completed."
    And the message "Fake payment completed" should not appear
    And the Pay button should not be visible
    And the user's cart should have 2 items
