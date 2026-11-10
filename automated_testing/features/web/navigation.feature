@web @regression @feature_catalog
Feature: Navigation
  As a visitor
  I want to browse the companies without signing in
  So that I can see the options before buying

  @smoke
  Scenario: TC-WEB-NAV-001 - See companies without logging in
    Given I am not logged in
    When I open the page "/"
    Then I should see 4 companies
    And I should see the Sign in link in the header
    And the cart counter should show "0"

  @smoke
  Scenario: TC-WEB-NAV-002 - Open each company
    Given I am not logged in
    Then each company below should open from the home page with 4 products:
      | pizzeria |
      | burgers  |
      | japanese |
      | juices   |

  Scenario: TC-WEB-NAV-003 - Go back through the header
    Given I am on the page "/companies/juices"
    And I should see 4 products
    When I click the header brand
    Then I should see 4 companies

  Scenario: TC-WEB-NAV-004 - Go back through the browser
    Given I am on the page "/"
    When I click the company "juices"
    Then I should see 4 products
    When I go back in the browser
    Then I should see 4 companies

  Scenario: TC-WEB-NAV-005 - Open a company by direct URL
    When I open the page "/companies/juices"
    Then the page title should be "Fresh Fruit Juices"
    And I should see 4 products

  Scenario Outline: <id> - <title>
    When I open the page "<path>"
    Then the page title should be "<message>"
    And I should see the link back to the companies

    Examples:
      | id             | title                | path                   | message           |
      | TC-WEB-NAV-006 | Non-existent company | /companies/nonexistent | Company not found |
      | TC-WEB-NAV-007 | Non-existent route   | /does-not-exist        | Page not found    |

  Scenario: TC-WEB-NAV-008 - Catalog fails to load
    Given the API responds with a 500 error on "**/api/companies"
    When I open the page "/"
    Then I should see the message "Internal error."

  @responsive
  Scenario: TC-WEB-NAV-009 - Mobile layout
    Given the screen is 360 pixels wide
    When I open the page "/"
    Then I should see 4 companies
    And the page should not scroll horizontally
