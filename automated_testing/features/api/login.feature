@api @regression @feature_login
Feature: Login
  As an API consumer
  I want to validate username and password
  So that access is granted only to correct credentials

  @smoke
  Scenario: TC-API-LOG-001 - Valid credentials
    Given a new user exists
    When I send "POST" to "/login" with the body:
      """
      { "username": "{user}", "password": "validPass1" }
      """
    Then the response status should be 200
    And the response should contain:
      """
      { "username": "{user}" }
      """
    And the response should not contain password data

  @smoke
  Scenario: TC-API-LOG-002 - Seed users can log in
    Then each user below should be able to log in with the password "loveMetalSongs@":
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |

  Scenario Outline: <id> - <title>
    When I send "POST" to "/login" with the body:
      """
      { "username": "<username>", "password": "<password>" }
      """
    Then the response should be a 401 error with code "INVALID_CREDENTIALS"
    And the error message should be "Invalid username or password."

    Examples:
      | id             | title                        | username      | password        |
      | TC-API-LOG-003 | Wrong password               | user_manual   | wrongPass1      |
      | TC-API-LOG-004 | Non-existent user            | {unique_name} | loveMetalSongs@ |
      | TC-API-LOG-005 | Password with different case | user_manual   | LOVEMETALSONGS@ |

  Scenario Outline: <id> - <title>
    When I send "POST" to "/login" with the body:
      """
      <body>
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"

    Examples:
      | id             | title             | body                                 |
      | TC-API-LOG-006 | Missing username  | { "password": "loveMetalSongs@" }    |
      | TC-API-LOG-007 | Missing password  | { "username": "user_manual" }        |
      | TC-API-LOG-008 | Non-string fields | { "username": 123, "password": 123 } |
