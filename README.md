# Test Automation with Playwright

[![Tests](https://github.com/devpabloassis/AutomatedTesting_Playwright/actions/workflows/tests.yml/badge.svg)](https://github.com/devpabloassis/AutomatedTesting_Playwright/actions/workflows/tests.yml)

**English** | [Português (Brasil)](README.pt-BR.md)

**API** and **Web** test automation project built with [Playwright](https://playwright.dev), TypeScript and **BDD** (Gherkin).

The repository has two parts:

- **`application/`**: a food marketplace, the system under test. It has an API and a Web UI, and it contains **defects inserted on purpose** so that the tests fail at known points.
- **`automated_testing/`**: the automated test project, with 385 tests covering API, Web, contracts, field domain characters and SQL injection.

## Highlights

- **BDD with Gherkin** through [playwright-bdd](https://vitalets.github.io/playwright-bdd): every scenario is traceable to a documented test case ID (`TC-API-*`, `TC-WEB-*`).
- **Page Object Model** plus a central **object map** with stable `id` selectors.
- **Contract testing** with JSON Schema and [Ajv](https://ajv.js.org), with readable violation messages.
- **Data-driven tests** with `Scenario Outline` (field domain and SQL injection payloads).
- **Parallel and isolated:** each scenario creates its own user through the API; persistence scenarios start their own server and database.
- **Known defects tracked with tags** (`@known_bug`), so the suite separates real regressions from expected failures.
- **Continuous integration** with GitHub Actions: type check, the full suite without known defects as the gate, and a check that the 15 known defects still fail.
- Reports in HTML and JUnit, with traces and screenshots on failure.

## How this project was built

The project simulates the workflow of a real QA team, from the user story to the automated suite:

1. **Specification first.** I wrote the product story, business rules, user stories and acceptance criteria in [`PRODUCT_SPEC.md`](docs/PRODUCT_SPEC.md). Testability is part of the requirements: every element used by the automation must have a unique, stable `id`.
2. **Intentional defects.** I left defects in the application on purpose, so the suite does **not** pass at 100%. This proves that the tests really detect problems, and shows how known defects are tracked without hiding new regressions.
3. **Test cases from the requirements.** The scenarios were extracted from the stories and acceptance criteria and documented with IDs in [`WEB_TEST_CASES.md`](docs/WEB_TEST_CASES.md) and [`API_TEST_CASES.md`](docs/API_TEST_CASES.md), since there is no separate test management tool connected to the project.
4. **Automation.** Each documented test case became a BDD scenario with the same ID, organized in 17 suites (`.feature` files) in the `web` and `api` folders.

**AI-assisted, QA-driven.** I used [Claude](https://www.anthropic.com/claude) (Anthropic) to extract the test scenarios from the requirements and to create the automated scenarios, following my specifications: test strategy, scope, coverage levels, architecture (BDD, Page Objects and object map), naming and tag conventions. I reviewed the scenarios and the code, and validated the results against the intentional defects.

### Why stable ids instead of XPath or self-healing locators

An `id` is a contract between development and QA: it does not change when the layout, the text or the styling changes, so a test breaks only when the behavior breaks. XPath tied to the page structure is fragile, and self-healing locators can silently "heal" onto the wrong element and hide a real regression. That is why the specification requires ids and the test project keeps all of them in a single object map.

## The system under test

A marketplace with 4 companies (pizzeria, burgers, Japanese food and juices), each with 4 products.

- Browse the catalog without logging in.
- Log in and build a cart.
- The cart accepts items from a single company. When a product from another company is chosen, a warning asks whether the cart should be cleared.
- Update quantities and remove items.
- Check out and make a fake payment.

Technology: Node.js 22, with no external dependencies. Data is stored in a JSON file.

Seed users: `user_manual`, `user_robot`, `user_hybrid` and `user_fail`, all with the password `loveMetalSongs@`.

### Intentional defects

These defects **must not be fixed**. They exist to show how the tests detect problems. In the code, they are marked with the `INTENTIONAL DEFECT` comment.

| Defect | Behavior |
|---|---|
| BUG-01 | When the company switch is confirmed, the cart is not cleared |
| BUG-02 | When an item quantity is updated, the value is stored doubled |
| BUG-03 | An order with items from different companies is accepted |
| BUG-04 | The company list returns a field that is not in the API contract |

## Structure

```text
AutomatedTesting_Playwright/
├── application/                 # System under test
│   ├── src/                     # API (server.js), catalog and storage
│   └── public/                  # Web UI
├── automated_testing/           # Test project
│   ├── features/
│   │   ├── api/                 # API scenarios in Gherkin
│   │   └── web/                 # Web scenarios in Gherkin
│   ├── steps/                   # Step definitions
│   ├── support/                 # Fixtures, API client, Page Objects and object map
│   ├── contracts/               # JSON Schemas for the contract tests
│   └── playwright.config.ts
└── docs/                        # Documentation
```

## Getting started

Prerequisite: Node.js 22 or later.

### Run the system manually

```bash
cd application
npm start
```

Open `http://127.0.0.1:3000`.

### Run the tests

```bash
cd automated_testing
npm install
npx playwright install chromium
npm test
```

There is no need to start the system first: Playwright starts the application on port `3100`, with a clean database, and stops it at the end.

| Command | What it runs |
|---|---|
| `npm test` | All tests |
| `npm run test:api` | API only |
| `npm run test:web` | Web only |
| `npm run test:smoke` | Smoke tests |
| `npm run test:contract` | Contract tests |
| `npm run test:no-bugs` | Everything except the intentional defect scenarios |
| `npm run test:known-bugs` | Only the intentional defect scenarios |
| `npm run report` | Opens the HTML report of the last run |

### Expected result

```text
  15 failed
  370 passed
```

The **15 failures are expected**: each one maps to one of the intentional defects. The reason for each failure is explained in the [test execution guide](docs/TEST_EXECUTION.md#52-expected-failures). For a run without failures, use `npm run test:no-bugs`.

## Example scenario

```gherkin
Feature: Company switch

  @smoke @known_bug
  Scenario: TC-WEB-SWT-006 - Counter after Yes
    Given I am logged in as a new user
    And the user's cart has the item "pizzeria/supreme/M"
    And I am on the page "/companies/burgers"
    When I add the product "double" to the cart
    And I answer the company switch warning with "Yes"
    Then the cart counter should show "1"
```

Each scenario creates its own user through the API. That is why the tests run in parallel without interfering with each other.

## Documentation

| Document | Content |
|---|---|
| [`docs/PRODUCT_SPEC.md`](docs/PRODUCT_SPEC.md) | Business rules, user stories, acceptance criteria and intentional defects |
| [`docs/API_ENDPOINTS.md`](docs/API_ENDPOINTS.md) | The 11 API endpoints, with examples, errors and contracts |
| [`docs/API_TEST_CASES.md`](docs/API_TEST_CASES.md) | Catalog of the API test cases |
| [`docs/WEB_TEST_CASES.md`](docs/WEB_TEST_CASES.md) | Catalog of the Web test cases |
| [`docs/TEST_EXECUTION.md`](docs/TEST_EXECUTION.md) | How to run, filter by tag and validate the results, and the reason for each expected failure |

## Tech stack

- [Playwright](https://playwright.dev) 1.65 with TypeScript
- [playwright-bdd](https://vitalets.github.io/playwright-bdd) for the Gherkin scenarios
- [Ajv](https://ajv.js.org) for JSON Schema validation in the contract tests
- Node.js 22 for the system under test, with no external dependencies
