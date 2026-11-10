# Test Execution Guide

This document explains how to run the Food Marketplace automated tests and how to validate the results.

## 1. Project structure

```text
AutomatedTesting_Playwright/
├── docs/                           # Product spec, API docs, test case repositories and this guide
├── application/                    # System under test: API, HTML and data
│   ├── src/
│   ├── public/
│   └── data/db.json                # Database for manual use (generated)
└── automated_testing/              # Playwright project with BDD
    ├── playwright.config.ts
    ├── package.json
    ├── features/
    │   ├── api/                    # API scenarios in Gherkin (.feature)
    │   └── web/                    # Web scenarios in Gherkin (.feature)
    ├── steps/                      # Step definitions: bind Gherkin sentences to code
    │   ├── common.steps.ts         # User and cart (API and Web)
    │   ├── api.steps.ts
    │   └── web.steps.ts
    ├── support/                    # Fixtures, API client, test data, Page Objects,
    │                               # object map (object-map.ts) and contract validator
    ├── contracts/                  # JSON Schemas of the API responses (contracts)
    └── .features-gen/              # Tests generated from the features (do not edit)
```

## 1.1 How the BDD scenarios work

The scenarios are written in Gherkin with the **playwright-bdd** library:

1. Each `.feature` describes scenarios with `Given`, `When` and `Then`, using the same IDs and tags as the test case repositories.
2. Each sentence matches a step in `steps/`, which uses the Page Objects, the object map and the API client.
3. The `bddgen` command converts the features into Playwright tests in the `.features-gen/` folder. The `npm run ...` scripts already run it before the tests.

Example:

```gherkin
@smoke @known_bug
Scenario: TC-WEB-SWT-006 - Counter after Yes
  When I add the product "double" to the cart
  And I answer the company switch warning with "Yes"
  Then I should see the message "Product added to the cart."
  And the cart counter should show "1"
```

Data-driven scenarios use `Scenario Outline` with an `Examples` table, where each row becomes a test.

In API requests, placeholders in braces are replaced with scenario values. Examples: `{user}` is the created user, `{item}` is the cart item, `{unique_name}` generates a new name and `{payload}` is the SQL injection payload.

## 1.2 Contract tests

The contract tests (`features/api/contract.feature`, tag `@contract`) check the **structure** of each response, not the values:

- Each response is compared with a JSON Schema in `automated_testing/contracts/`, using the `ajv` library.
- The contract requires the mandatory fields with the right type and format and **rejects extra fields**.
- There are success and error scenarios for the 11 endpoints, documented in [`API_ENDPOINTS.md`](./API_ENDPOINTS.md).

```gherkin
Scenario: TC-API-CON-008 - List companies
  When I send "GET" to "/companies"
  Then the response status should be 200
  And the response should follow the "companies" contract
```

When the response does not follow the contract, the error lists each violation:

```text
- Array []
+ Array [
+   "[0].commissionPercent: field not allowed by the contract",
+   ...
+ ]
```

## 2. Prerequisites

- Node.js 22 or later.
- On the first run, install the dependencies:

```bash
cd automated_testing
npm install
npx playwright install chromium
```

All the following commands must be run inside `automated_testing/`.

## 3. How the test environment works

**There is no need to start the application before the tests.** Playwright starts the system automatically on port `3100` and stops it at the end.

- Each run starts with a clean database at `automated_testing/.test-data/db.json`. The manual database, `application/data/db.json`, is not changed.
- The tests create their own users through the API, so they run in parallel without interfering with each other.
- The persistence scenarios (`TC-API-GEN-010` to `012`) start their own servers from port `3200`, since they need to restart the system.
- There are no automatic retries, so the intentional defects show up as direct failures.

To use another port if `3100` is busy:

```bash
TEST_PORT=3110 npm test
```

To use the system manually:

```bash
cd application
npm start
```

Then open `http://127.0.0.1:3000`.

## 4. Commands

| Goal | Command | Tests | Passed | Failed |
|---|---|---:|---:|---:|
| Everything | `npm test` | 385 | 370 | 15 |
| API only | `npm run test:api` | 314 | 307 | 7 |
| Web only | `npm run test:web` | 71 | 63 | 8 |
| Smoke | `npm run test:smoke` | 43 | 35 | 8 |
| Regression | `npm run test:regression` | 385 | 370 | 15 |
| Login | `npm run test:login` | 37 | 37 | 0 |
| Cart | `npm run test:cart` | 73 | 66 | 7 |
| Field domain | `npm run test:domain` | 57 | 57 | 0 |
| SQL injection | `npm run test:sqli` | 137 | 137 | 0 |
| Contract | `npm run test:contract` | 28 | 27 | 1 |
| Without known defects | `npm run test:no-bugs` | 370 | 370 | 0 |
| Known defects only | `npm run test:known-bugs` | 15 | 0 | 15 |

The repositories have 266 scenario IDs. The total is 385 because 17 SQL injection scenarios run once for each of the 8 payloads.

### Custom filters

When using `npx playwright` directly, run `npx bddgen` first whenever a `.feature` or a step changes.

```bash
# One tag
npx playwright test --grep @feature_payment

# One tag or another
npx playwright test --grep "@feature_login|@feature_payment"

# Both tags at the same time
npx playwright test --grep "(?=.*@smoke)(?=.*@feature_cart)"

# A tag in a single project
npx playwright test --project=web-chromium --grep @smoke

# A single scenario by ID
npx playwright test --grep TC-WEB-CRT-004

# List which tests would run, without running them
npx playwright test --list --grep @smoke
```

Available tags: `@api`, `@web`, `@regression`, `@smoke`, `@known_bug`, `@domain`, `@sqli`, `@contract`, `@security`, `@persistence`, `@responsive`, `@feature_user`, `@feature_login`, `@feature_catalog`, `@feature_cart`, `@feature_company_switch`, `@feature_checkout` and `@feature_payment`.

### Debugging modes

| Goal | Command |
|---|---|
| Interactive UI mode | `npm run test:ui` |
| Watch the browser during the test | `npx playwright test --project=web-chromium --headed` |
| Debug step by step | `npx playwright test --grep TC-WEB-CRT-004 --debug` |

## 5. How to validate the results

### 5.1 Expected result

`npm test` must finish with **370 passed and 15 failed**:

```text
  15 failed
    ...
  370 passed
```

Because there are failures, the command exits with **code 1**. While the intentional defects exist, this is the correct result for the full suite.

For a run without failures, use `npm run test:no-bugs`, which must exit with code 0.

### 5.2 Expected failures

The 15 scenarios below validate the **correct behavior** and fail because the system has 4 defects inserted on purpose. The defects are described in section 10 of the [product specification](./PRODUCT_SPEC.md) and marked in the code with the `INTENTIONAL DEFECT` comment. All 15 scenarios have the `@known_bug` tag.

Summary:

| Defect | Endpoint with the defect | API | Web | Total |
|---|---|---:|---:|---:|
| BUG-01 — Cart is not cleared when switching company | `POST /users/:username/cart/items` | 1 | 5 | 6 |
| BUG-02 — Quantity is doubled when updating an item | `PATCH /users/:username/cart/items/:itemId` | 4 | 2 | 6 |
| BUG-03 — Order with different companies is accepted | `POST /users/:username/cart/checkout` | 1 | 1 | 2 |
| BUG-04 — Company list breaks the contract | `GET /companies` | 1 | 0 | 1 |
| **Total** | | **7** | **8** | **15** |

#### BUG-01 — Cart is not cleared when switching company

**Why it fails:** when the company switch is confirmed (`replaceCart: true`, or **Yes** in the UI warning), the API should empty the cart before adding the new product. The line that does this is missing in `application/src/server.js` (`addCartItem`). The cart ends up with the old item and the new one, from different companies. The header counter shows `totalItems`, the sum of the quantities of that cart, so it is wrong as well.

| Scenario | Type | What it validates | Expected | Actual | Failing step |
|---|---|---|---|---|---|
| `TC-API-CRT-020` | API | Add an item from another company with `replaceCart: true` | Items: `double` | Items: `supreme`, `double` | `And the returned cart should contain only the products "double"` |
| `TC-WEB-SWT-002` | Web | Clicking **Yes** clears the cart | Items: `double` | Items: `supreme`, `double` | `And the user's cart should contain only the products "double"` |
| `TC-WEB-SWT-006` | Web | Counter after **Yes** | `1` | `2` | `And the cart counter should show "1"` |
| `TC-WEB-SWT-007` | Web | Counter after **Yes**, with 3 units before | `1` | `4` | `And the cart counter should show "1"` |
| `TC-WEB-SWT-008` | Web | Counter after **Yes** and page reload | `1` | `2` | `Then the cart counter should show "1"` |
| `TC-WEB-SWT-009` | Web | After **Yes**, add another product from the new company | No new warning | Warning shown again, since the pizza is still in the cart | `Then the company switch warning should not be visible` |

#### BUG-02 — Quantity is doubled when updating an item

**Why it fails:** when the quantity is updated, the API stores twice the value entered (`item.quantity = body.quantity * 2`, in `updateCartItem`). Subtotal, total and counter are calculated from that wrong quantity.

| Scenario | Type | What it validates | Expected | Actual | Failing step |
|---|---|---|---|---|---|
| `TC-API-CRT-030` | API | Update the quantity to 3 | Quantity `3` | Quantity `6` | `And the response should contain:` |
| `TC-API-CRT-031` | API | Update to the minimum (1) | Quantity `1` | Quantity `2` | `And the response should contain:` |
| `TC-API-CRT-032` | API | Update to the maximum (99) | Quantity `99` | Quantity `198`, above the BR-10 limit | `And the response should contain:` |
| `TC-API-CRT-033` | API | Recalculate subtotal and total | Subtotal `15870` | Subtotal `31740` | `And the response should contain:` |
| `TC-WEB-CRT-004` | Web | Update the quantity on screen | Field with `3` | Field with `6` | `And the on-screen quantity of the item "supreme/M" should be "3"` |
| `TC-WEB-CRT-005` | Web | Amounts recalculated on screen | Subtotal `$158.70` | Subtotal `$317.40` | `And the subtotal of the item "supreme/M" should be "$158.70"` |

#### BUG-03 — Order with different companies is accepted

**Why it fails:** on checkout, the API should reject a cart with different companies (422 `CART_MIXED_COMPANIES`). The `checkout` route only validates the empty cart and returns 200. The UI then shows `Order confirmed` and the **Pay** button. The payment route does not have the defect and rejects that cart.

This mixed cart can only be built because of BUG-01. That is why the setup of these scenarios depends on it.

| Scenario | Type | What it validates | Expected | Actual | Failing step |
|---|---|---|---|---|---|
| `TC-API-ORD-003` | API | Check out a cart with different companies | 422 `CART_MIXED_COMPANIES` | 200 `READY_FOR_PAYMENT` | `Then the response should be a 422 error with code "CART_MIXED_COMPANIES"` |
| `TC-WEB-CHK-002` | Web | Message when checking out with different companies | `The cart has items from different companies. The order cannot be completed.` | `Order confirmed` | `Then I should see the message "The cart has items from different companies..."` |

#### BUG-04 — Company list breaks the contract

**Why it fails:** `GET /companies` adds the internal field `commissionPercent` to each company, and that field is not in the `companies` contract (`automated_testing/contracts/`). The contract does not accept extra fields. The UI and the functional tests do not notice the extra field: only contract validation detects the defect. `GET /companies/:companyId` does not have the defect, which is why `TC-API-CON-009` passes.

| Scenario | Type | What it validates | Expected | Actual | Failing step |
|---|---|---|---|---|---|
| `TC-API-CON-008` | API | `GET /companies` response follows the contract | No violations | `[0].commissionPercent: field not allowed by the contract`, and the same for `[1]`, `[2]` and `[3]` | `And the response should follow the "companies" contract` |

#### Scenarios that depend on defects but pass

These scenarios use BUG-01 only to build a cart with different companies. What they validate works correctly, so they pass and do **not** have `@known_bug`:

| Scenario | What it validates |
|---|---|
| `TC-API-ORD-013` | `POST /cart/pay` rejects a mixed cart with 422 `CART_MIXED_COMPANIES` |
| `TC-API-CON-025` | The 422 payment error with a mixed cart follows the `error` contract |
| `TC-WEB-PAY-005` | The UI rejects the payment of a mixed cart and keeps the items |
| `TC-WEB-SWT-010` | The counter follows the real cart after **Yes**. It confirms that the counter is updated and that the error is in the cart, not in the counter |

#### If a defect is fixed

| Fixed defect | Scenarios that start to pass | Side effect |
|---|---|---|
| BUG-01 | The 6 in the BUG-01 table | `TC-API-ORD-003`, `TC-WEB-CHK-002`, `TC-API-ORD-013`, `TC-API-CON-025` and `TC-WEB-PAY-005` can no longer build the mixed cart and need a different setup |
| BUG-02 | The 6 in the BUG-02 table | None |
| BUG-03 | `TC-API-ORD-003` and `TC-WEB-CHK-002` | None |
| BUG-04 | `TC-API-CON-008` | None |

### 5.3 Validation checklist

1. Check that the summary shows 370 passed and 15 failed.
2. Compare the failed IDs with the table in section 5.2.
3. Check in the report that the expected and actual values of each failure match the table.
4. Run `npm run test:no-bugs` and confirm 370 passed.

| Situation | Interpretation |
|---|---|
| Only the 15 scenarios above failed, with the values in the table | Valid run |
| A scenario outside the table failed | Possible regression or environment issue: investigate |
| A scenario in the table passed | The defect may have been fixed: confirm in the system |
| A scenario in the table failed with a different value or error | The failure has another cause: investigate |
| The total number of tests is not 385 | A filter was applied or the tests changed: check the command |

### 5.4 Generated reports

| Report | Location | Use |
|---|---|---|
| Console | Terminal output | Follow the run and see the summary |
| HTML | `automated_testing/playwright-report/` | Detailed analysis, with filters by status and tag |
| JUnit | `automated_testing/test-results/junit.xml` | Integration with CI tools |
| Evidence | `automated_testing/test-results/` | Screenshots and traces of the failed tests |

To open the HTML report:

```bash
npm run report
```

In the report, you can filter by **Failed** and open each test to see the error and the steps. Failed Web tests also include a screenshot and a trace.

To open a trace directly:

```bash
npx playwright show-trace test-results/<test-folder>/trace.zip
```

The Trace Viewer shows each action with the page state, the requests and the console. The `test-results/` folder is cleaned on every run, and the report is replaced.

## 6. After fixing a defect

The scenarios in table 5.2 will pass once the corresponding defect is fixed in `application/src/server.js`. In that case:

1. Remove the `@known_bug` tag from the fixed scenarios and update section 10 of the product specification.
2. With **BUG-01** fixed, `TC-API-ORD-003`, `TC-API-ORD-013`, `TC-WEB-CHK-002` and `TC-WEB-PAY-005` can no longer build a cart with different companies. They will need a different setup or must be removed, even while **BUG-03** is still present.

## 7. Troubleshooting

| Symptom | Solution |
|---|---|
| `Executable doesn't exist` | Run `npx playwright install chromium` |
| `http://127.0.0.1:3100/... is already used` | Stop the process using the port or set `TEST_PORT` |
| `Cannot find module '@playwright/test'` | Run `npm install` inside `automated_testing/` |
| `No tests found` | Run `npx bddgen`, check that you are in `automated_testing/` and that the tag exists |
| `Missing step definitions` | The `.feature` sentence does not match any step. `bddgen` prints the suggested code to create the step in `steps/` |
| `TC-API-GEN-010` to `012` fail because the server did not start | Free the ports starting at `3200` |
| Slow Web tests or timeouts | Reduce parallelism: `npx playwright test --workers=2` |
