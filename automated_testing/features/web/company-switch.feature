@web @regression @feature_company_switch
Feature: Company switch
  As a customer
  I want to be warned when I choose a product from another company
  So that I can decide whether to switch my order

  Background:
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/companies/burgers"
    And the cart counter should show "1"

  @smoke
  Scenario: TC-WEB-SWT-001 - Show the warning
    When I add the product "double" to the cart
    Then the company switch warning should show the text "the cart will be cleared"
    And the company switch warning should have the Yes and No options

  # Expected failure: BUG-01.
  @smoke @known_bug
  Scenario: TC-WEB-SWT-002 - Confirming with Yes clears the cart
    When I add the product "double" to the cart
    And I answer the company switch warning with "Yes"
    Then I should see the message "Product added to the cart."
    And the user's cart should contain only the products "double"
    When I open the page "/cart"
    Then I should see the item "double/R" in the cart
    And the item "supreme/M" should not be in the cart

  @smoke
  Scenario: TC-WEB-SWT-003 - Declining with No
    When I add the product "double" to the cart
    And I answer the company switch warning with "No"
    Then the company switch warning should not be visible
    And the cart counter should show "1"
    And the user's cart should contain only the products "supreme"

  Scenario: TC-WEB-SWT-004 - Close the warning with Esc
    When I add the product "double" to the cart
    And I close the warning with the Esc key
    Then the company switch warning should not be visible
    And the cart counter should show "1"
    And the user's cart should contain only the products "supreme"

  Scenario: TC-WEB-SWT-005 - Esc after a previous Yes
    When I add the product "double" to the cart
    And I answer the company switch warning with "Yes"
    Then I should see the message "Product added to the cart."
    When I navigate through the site to the company "juices"
    And I save the cart state
    And I add the product "orange" to the cart
    And I close the warning with the Esc key
    Then the company switch warning should not be visible
    And the user's cart should not have changed

  # Cart counter (badge) after the company switch.
  # The counter shows the sum of the quantities in the cart returned by the API.

  # Expected failure: BUG-01.
  @smoke @known_bug
  Scenario: TC-WEB-SWT-006 - Counter after Yes
    When I add the product "double" to the cart
    And I answer the company switch warning with "Yes"
    Then I should see the message "Product added to the cart."
    And the cart counter should show "1"

  # Expected failure: BUG-01.
  @known_bug
  Scenario: TC-WEB-SWT-007 - Counter after Yes with several units
    Given the user's cart has the item "pizzeria/pepperoni/S" with quantity 2
    When I reload the page
    Then the cart counter should show "3"
    When I add the product "double" to the cart
    And I answer the company switch warning with "Yes"
    Then I should see the message "Product added to the cart."
    And the cart counter should show "1"

  # Expected failure: BUG-01.
  @known_bug
  Scenario: TC-WEB-SWT-008 - Counter after Yes and page reload
    When I add the product "double" to the cart
    And I answer the company switch warning with "Yes"
    Then I should see the message "Product added to the cart."
    When I reload the page
    Then the cart counter should show "1"
    When I open the page "/cart"
    Then the cart counter should show "1"

  # Expected failure: BUG-01.
  @known_bug
  Scenario: TC-WEB-SWT-009 - Counter after Yes and another item from the same company
    When I add the product "double" to the cart
    And I answer the company switch warning with "Yes"
    Then I should see the message "Product added to the cart."
    When I add the product "classic" to the cart
    Then the company switch warning should not be visible
    And the cart counter should show "2"

  Scenario: TC-WEB-SWT-010 - Counter matches the cart after Yes
    When I add the product "double" to the cart
    And I answer the company switch warning with "Yes"
    Then I should see the message "Product added to the cart."
    And the cart counter should match the user's cart
    When I open the page "/cart"
    Then the cart counter should match the user's cart

  Scenario: TC-WEB-SWT-011 - Counter after No with several units
    Given the user's cart has the item "pizzeria/pepperoni/S" with quantity 2
    When I reload the page
    Then the cart counter should show "3"
    When I add the product "double" to the cart
    And I answer the company switch warning with "No"
    Then the company switch warning should not be visible
    And the cart counter should show "3"
