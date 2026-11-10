@web @regression @feature_catalog
Feature: Products
  As a visitor
  I want to see the products with their sizes and prices
  So that I can choose what to order

  @smoke
  Scenario: TC-WEB-PRD-001 - Default price with size
    When I open the page "/companies/pizzeria"
    Then the selected size of the product "supreme" should be "S"
    And the price of the product "supreme" should be "$38.90"

  Scenario: TC-WEB-PRD-002 - Change the pizza size
    Given I am on the page "/companies/pizzeria"
    When I select the size "Medium" for the product "supreme"
    Then the price of the product "supreme" should be "$52.90"
    When I select the size "Large" for the product "supreme"
    Then the price of the product "supreme" should be "$66.90"

  Scenario: TC-WEB-PRD-003 - Change the juice size
    Given I am on the page "/companies/juices"
    When I select the size "Large" for the product "orange"
    Then the price of the product "orange" should be "$14.90"

  Scenario Outline: <id> - <title>
    When I open the page "/companies/<company>"
    Then the price of the product "<product>" should be "<price>"
    And the product "<product>" should not have a size selector

    Examples:
      | id             | title                      | company  | product         | price  |
      | TC-WEB-PRD-004 | Burger without size        | burgers  | double          | $36.90 |
      | TC-WEB-PRD-005 | Japanese food without size | japanese | philly-hot-roll | $29.90 |
