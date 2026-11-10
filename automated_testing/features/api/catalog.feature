@api @regression @feature_catalog
Feature: Catalog
  As an API consumer
  I want to fetch companies and products
  So that I can show the catalog to customers

  @smoke
  Scenario: TC-API-CAT-001 - List companies
    When I send "GET" to "/companies"
    Then the response status should be 200
    And the response should have 4 companies with 4 products each

  Scenario: TC-API-CAT-002 - Catalog prices
    Then the catalog prices in cents should be:
      | company  | product          | prices         |
      | pizzeria | supreme          | 3890,5290,6690 |
      | pizzeria | pepperoni        | 3490,4890,6290 |
      | pizzeria | chicken-cheese   | 3690,5090,6490 |
      | pizzeria | margherita       | 3290,4690,6090 |
      | burgers  | vegan            | 3190           |
      | burgers  | classic          | 2990           |
      | burgers  | egg-burger       | 2690           |
      | burgers  | double           | 3690           |
      | japanese | beef-yakisoba    | 3490           |
      | japanese | chicken-yakisoba | 3190           |
      | japanese | mixed-yakisoba   | 3790           |
      | japanese | philly-hot-roll  | 2990           |
      | juices   | orange           | 890,1190,1490  |
      | juices   | pineapple        | 990,1290,1590  |
      | juices   | guava            | 950,1250,1550  |
      | juices   | acerola          | 900,1200,1500  |

  Scenario: TC-API-CAT-003 - Fetch each company
    Then each company below should be returned when fetched by its id:
      | pizzeria |
      | burgers  |
      | japanese |
      | juices   |

  Scenario: TC-API-CAT-004 - Size options
    Then the products of the companies "pizzeria, juices" should have the options "S, M, L"

  Scenario: TC-API-CAT-005 - Single option
    Then the products of the companies "burgers, japanese" should have the options "R"

  Scenario Outline: <id> - <title>
    When I send "GET" to "/companies/<company>"
    Then the response should be a 404 error with code "COMPANY_NOT_FOUND"

    Examples:
      | id             | title                 | company     |
      | TC-API-CAT-006 | Non-existent company  | nonexistent |
      | TC-API-CAT-007 | Different letter case | Pizzeria    |
