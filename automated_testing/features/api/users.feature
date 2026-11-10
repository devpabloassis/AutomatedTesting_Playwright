@api @regression @feature_user
Feature: Users
  As an API consumer
  I want to create and fetch users
  So that customers can use the system

  @smoke
  Scenario: TC-API-USR-001 - Create a valid user
    When I send "POST" to "/users" with the body:
      """
      { "username": "{unique_name}", "password": "validPass1" }
      """
    Then the response status should be 201
    And the response should contain:
      """
      { "username": "{generated_name}" }
      """
    And the response should have the creation date
    And the response should not contain password data

  Scenario Outline: <id> - <title>
    When I send "POST" to "/users" with the body:
      """
      { "username": "<username>", "password": "<password>" }
      """
    Then the response status should be 201

    Examples:
      | id             | title                   | username        | password   |
      | TC-API-USR-002 | Minimum username length | {name_3_chars}  | validPass1 |
      | TC-API-USR-003 | Maximum username length | {name_30_chars} | validPass1 |
      | TC-API-USR-004 | Minimum password length | {unique_name}   | 12345678   |

  Scenario: TC-API-USR-005 - Username is case-sensitive
    When I send "POST" to "/users" with the body:
      """
      { "username": "Case_{unique_name}", "password": "validPass1" }
      """
    Then the response status should be 201
    When I send "POST" to "/users" with the body:
      """
      { "username": "case_{generated_name}", "password": "validPass1" }
      """
    Then the response status should be 201

  Scenario: TC-API-USR-006 - Username already exists
    Given a new user exists
    When I send "POST" to "/users" with the body:
      """
      { "username": "{user}", "password": "validPass1" }
      """
    Then the response should be a 409 error with code "USER_ALREADY_EXISTS"

  Scenario Outline: <id> - <title>
    When I send "POST" to "/users" with the body:
      """
      <body>
      """
    Then the response should be a 400 error with code "VALIDATION_ERROR"

    Examples:
      | id             | title                  | body                                                                        |
      | TC-API-USR-007 | Username below minimum | { "username": "ab", "password": "validPass1" }                              |
      | TC-API-USR-008 | Username above maximum | { "username": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "password": "validPass1" } |
      | TC-API-USR-009 | Password below minimum | { "username": "{unique_name}", "password": "1234567" }                      |
      | TC-API-USR-010 | Missing username       | { "password": "validPass1" }                                                |
      | TC-API-USR-011 | Missing password       | { "username": "{unique_name}" }                                             |
      | TC-API-USR-013 | Malformed JSON         | {"username":                                                                |
      | TC-API-USR-014 | Body is not an object  | []                                                                          |

  Scenario: TC-API-USR-012 - Empty body
    When I send "POST" to "/users" without a body
    Then the response should be a 400 error with code "VALIDATION_ERROR"

  Scenario: TC-API-USR-015 - Body larger than 100 KB
    When I send "POST" to "/users" with a 150 KB password
    Then the response should be a 400 error with code "VALIDATION_ERROR"

  @smoke
  Scenario: TC-API-USR-020 - Fetch an existing user
    Given a new user exists
    When I send "GET" to "/users/{user}"
    Then the response status should be 200
    And the response should contain:
      """
      { "username": "{user}" }
      """
    And the response should have the creation date
    And the response should not contain password data

  @smoke
  Scenario: TC-API-USR-021 - Seed users exist
    Then each user below should be found:
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |

  Scenario: TC-API-USR-022 - Non-existent user
    When I send "GET" to "/users/{unique_name}"
    Then the response should be a 404 error with code "USER_NOT_FOUND"

  Scenario: TC-API-USR-023 - Different letter case
    When I send "GET" to "/users/User_Manual"
    Then the response should be a 404 error with code "USER_NOT_FOUND"
