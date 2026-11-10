@web @regression @feature_cart
Feature: Cart
  As a customer
  I want to review, update and remove cart items
  So that I can adjust my order

  @smoke
  Scenario: TC-WEB-CRT-001 - Show item details
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    When I open the page "/cart"
    Then the row of the item "supreme/M" should show:
      | Supreme             |
      | Noble Oven Pizzeria |
      | Medium              |
      | $52.90              |
    And the on-screen quantity of the item "supreme/M" should be "1"
    And the subtotal of the item "supreme/M" should be "$52.90"
    And the cart total should be "$52.90"

  Scenario: TC-WEB-CRT-002 - Empty cart
    Given I am logged in as a new user
    When I open the page "/cart"
    Then I should see the empty cart notice
    And I should see the View companies link

  Scenario: TC-WEB-CRT-003 - Cart without logging in
    Given I am not logged in
    When I open the page "/cart"
    Then I should see the cart sign-in notice "Sign in to view your cart."
    And I should see the cart's Sign in button

  # Expected failure: BUG-02.
  @smoke @known_bug
  Scenario: TC-WEB-CRT-004 - Update quantity
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/cart"
    When I change the quantity of the item "supreme/M" to "3"
    Then the cart total should no longer be "$52.90"
    And the on-screen quantity of the item "supreme/M" should be "3"

  # Expected failure: BUG-02.
  @known_bug
  Scenario: TC-WEB-CRT-005 - Recalculate amounts
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/cart"
    When I change the quantity of the item "supreme/M" to "3"
    Then the cart total should no longer be "$52.90"
    And the subtotal of the item "supreme/M" should be "$158.70"
    And the cart total should be "$158.70"
    And the cart counter should show "3"

  Scenario Outline: <id> - <title>
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/cart"
    When I change the quantity of the item "supreme/M" to "<value>"
    Then I should see the message "Quantity must be an integer from 1 to 99."
    And the item quantity in the cart should be 1

    Examples:
      | id             | title                  | value |
      | TC-WEB-CRT-006 | Zero quantity          | 0     |
      | TC-WEB-CRT-007 | Quantity above maximum | 100   |
      | TC-WEB-CRT-008 | Negative quantity      | -1    |
      | TC-WEB-CRT-009 | Decimal quantity       | 1.5   |
      | TC-WEB-CRT-010 | Empty quantity         |       |

  @smoke
  Scenario: TC-WEB-CRT-011 - Remove one of several items
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    And the user's cart has the item "pizzeria/pepperoni/S"
    And I am on the page "/cart"
    When I remove the item "pepperoni/S"
    Then the item "pepperoni/S" should not be in the cart
    And the cart total should be "$52.90"
    And the cart counter should show "1"

  Scenario: TC-WEB-CRT-012 - Remove the last item
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/cart"
    When I remove the item "supreme/M"
    Then I should see the empty cart notice
    And the cart counter should show "0"

  Scenario: TC-WEB-CRT-013 - Independent carts
    Given another new user exists with the item "pizzeria/supreme/M"
    And I am logged in as a new user
    When I open the page "/cart"
    Then I should see the empty cart notice

  Scenario: TC-WEB-CRT-014 - Cart is kept
    Given a new user exists
    And the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/login"
    When I log in with the created user
    Then I should see the created user in the header
    When I open the page "/cart"
    Then I should see the item "supreme/M" in the cart
    When I reload the page
    Then I should see the item "supreme/M" in the cart
    When I click Sign out
    Then I should see 4 companies
    When I open the page "/login"
    And I log in with the created user
    Then I should see the created user in the header
    When I open the page "/cart"
    Then I should see the item "supreme/M" in the cart
