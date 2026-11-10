@web @regression @feature_login
Feature: Login
  As a customer
  I want to sign in with username and password
  So that I can use my cart

  @smoke
  Scenario: TC-WEB-LOG-001 - Valid login
    Given a new user exists
    And I am on the page "/login"
    When I log in with the created user
    Then I should see 4 companies
    And I should see the created user in the header
    And I should see the Sign out button

  Scenario: TC-WEB-LOG-002 - Seed users can sign in
    Then each user below should be able to sign in and sign out with the password "loveMetalSongs@":
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |

  Scenario: TC-WEB-LOG-003 - Session is kept
    Given I am logged in as a new user
    When I open the page "/"
    Then I should see the created user in the header
    When I reload the page
    Then I should see the created user in the header

  @smoke
  Scenario: TC-WEB-LOG-004 - Return to the company
    Given a new user exists
    And I am on the page "/companies/pizzeria"
    When I add the product "supreme" to the cart
    Then I should be on the login page
    When I log in with the created user
    Then I should be on the page "/companies/pizzeria"
    And I should see the created user in the header
    And the user's cart should have 0 items

  Scenario: TC-WEB-LOG-005 - Return to the cart
    Given a new user exists
    And I am on the page "/cart"
    When I click the cart's Sign in button
    And I log in with the created user
    Then I should be on the page "/cart"

  @smoke
  Scenario: TC-WEB-LOG-006 - Sign out
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/"
    And the cart counter should show "1"
    When I click Sign out
    Then I should see the Sign in link in the header
    And the cart counter should show "0"
    And I should be on the page "/"

  Scenario: TC-WEB-LOG-007 - Open login while logged in
    Given I am logged in as a new user
    When I open the page "/login"
    Then I should see 4 companies
    And I should be on the page "/"

  @smoke
  Scenario: TC-WEB-LOG-008 - Wrong password
    Given I am on the page "/login"
    When I log in with the username "user_manual" and the password "wrongPass1"
    Then I should see the message "Invalid username or password."
    And I should not be logged in

  Scenario: TC-WEB-LOG-009 - Non-existent user
    Given I am on the page "/login"
    When I log in with a non-existent user and the password "loveMetalSongs@"
    Then I should see the message "Invalid username or password."
    And I should not be logged in

  Scenario: TC-WEB-LOG-010 - Empty fields
    Given I am monitoring login requests
    And I am on the page "/login"
    When I click Sign in without filling in the fields
    Then the username field should be focused
    And I should be on the page "/login"
    And no login request should have been sent

  @security
  Scenario: TC-WEB-LOG-011 - External redirect blocked
    Given I am on the page "/login?next=//example.com"
    When I log in with the username "user_manual" and the password "loveMetalSongs@"
    Then I should see 4 companies
    And I should stay on the system
