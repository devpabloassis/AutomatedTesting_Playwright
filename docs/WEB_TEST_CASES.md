# Test Case Repository — Web

> **Note:** this file exists only because no test management tool is integrated into this project. It is a way to **simulate** a test case repository that would normally live in a dedicated tool.

| Field | Value |
|---|---|
| System | Food Marketplace |
| Based on | [`PRODUCT_SPEC.md`](./PRODUCT_SPEC.md) v1.0 |
| URL | `http://127.0.0.1:3000` |
| Related repository | [`API_TEST_CASES.md`](./API_TEST_CASES.md) |

## 1. Conventions

- **Type:** `H` happy path, `A` alternative flow, `E` exception flow.
- **Expected result:** always describes the correct behavior. When an intentional defect prevents that result, the row shows **Expected failure** and the actual value.
- **Tags:** every scenario also belongs to `@web` and `@regression`. The column shows the others.
- **Test data:** scenarios that use a cart create their own user through the API and start with that user's session, so they can run in parallel.
- **Setup through the API:** when a precondition is not what is being validated, it is built through the API.

## 2. Navigation and catalog (BR-01, US-01)

| ID | Scenario | Type | Precondition | Steps | Expected result | Tags |
|---|---|---|---|---|---|---|
| TC-WEB-NAV-001 | See companies without logging in | H | No session | Open `/` | 4 companies shown, **Sign in** link visible and counter 0 | `@smoke @feature_catalog` |
| TC-WEB-NAV-002 | Open each company | H | No session | Click each company | URL `/companies/<id>` and 4 products shown | `@smoke @feature_catalog` |
| TC-WEB-NAV-003 | Go back through the header | A | On a company page | Click **Food Marketplace** | Company list shown | `@feature_catalog` |
| TC-WEB-NAV-004 | Go back through the browser | A | On a company page, coming from `/` | Use the back button | Company list shown | `@feature_catalog` |
| TC-WEB-NAV-005 | Open a company by direct URL | A | No session | Open `/companies/juices` | **Fresh Fruit Juices** with 4 products | `@feature_catalog` |
| TC-WEB-NAV-006 | Non-existent company | E | — | Open `/companies/nonexistent` | `Company not found` and a back link | `@feature_catalog` |
| TC-WEB-NAV-007 | Non-existent route | E | — | Open `/does-not-exist` | `Page not found` and a back link | `@feature_catalog` |
| TC-WEB-NAV-008 | Catalog fails to load | E | Companies API responding 500 (mocked) | Open `/` | Error message returned by the API | `@feature_catalog` |
| TC-WEB-NAV-009 | Mobile layout | A | 360 px screen | Open `/` | Companies visible, no horizontal scroll | `@responsive` |

## 3. Products (US-01)

| ID | Scenario | Type | Precondition | Steps | Expected result | Tags |
|---|---|---|---|---|---|---|
| TC-WEB-PRD-001 | Default price with size | H | On `/companies/pizzeria` | Look at **Supreme** | Size **Small** and `$38.90` | `@smoke @feature_catalog` |
| TC-WEB-PRD-002 | Change the pizza size | H | On `/companies/pizzeria` | Select **Medium** and then **Large** on **Supreme** | `$52.90` and then `$66.90` | `@feature_catalog` |
| TC-WEB-PRD-003 | Change the juice size | A | On `/companies/juices` | Select **Large** on **Orange** | `$14.90` | `@feature_catalog` |
| TC-WEB-PRD-004 | Burger without size | A | On `/companies/burgers` | Look at **Double** | `$36.90`, no size selector | `@feature_catalog` |
| TC-WEB-PRD-005 | Japanese food without size | A | On `/companies/japanese` | Look at **Philadelphia Hot Roll** | `$29.90`, no size selector | `@feature_catalog` |

## 4. Login (BR-02, BR-03, US-02)

| ID | Scenario | Type | Precondition | Steps | Expected result | Tags |
|---|---|---|---|---|---|---|
| TC-WEB-LOG-001 | Valid login | H | No session | Enter a valid username and password and click **Sign in** | Home page, username in the header and **Sign out** option | `@smoke @feature_login` |
| TC-WEB-LOG-002 | Seed users can sign in | H | No session | Sign in with each of the 4 users | Login granted to all of them | `@feature_login` |
| TC-WEB-LOG-003 | Session is kept | A | Logged in | Reload the page | User still in the header | `@feature_login` |
| TC-WEB-LOG-004 | Return to the company | A | No session, on `/companies/pizzeria` | Click **Add to cart**; sign in | Back on `/companies/pizzeria` and the cart is still empty | `@smoke @feature_login` |
| TC-WEB-LOG-005 | Return to the cart | A | No session, on `/cart` | Click **Sign in**; enter the credentials | Back on `/cart` | `@feature_login` |
| TC-WEB-LOG-006 | Sign out | H | Logged in | Click **Sign out** | Home page, **Sign in** link and counter 0 | `@smoke @feature_login` |
| TC-WEB-LOG-007 | Open login while logged in | A | Logged in | Open `/login` | Redirected to the home page | `@feature_login` |
| TC-WEB-LOG-008 | Wrong password | E | No session | Enter a wrong password | `Invalid username or password.`, no session | `@smoke @feature_login` |
| TC-WEB-LOG-009 | Non-existent user | E | No session | Enter an unregistered user | `Invalid username or password.`, no session | `@feature_login` |
| TC-WEB-LOG-010 | Empty fields | E | No session | Click **Sign in** without filling in the fields | Stays on the login page, no API call | `@feature_login` |
| TC-WEB-LOG-011 | External redirect blocked | E | No session | Open `/login?next=//example.com`; sign in | Stays on the system, on the home page | `@feature_login @security` |

## 5. Add to cart (BR-02, BR-09, BR-10, US-03)

| ID | Scenario | Type | Precondition | Steps | Expected result | Tags |
|---|---|---|---|---|---|---|
| TC-WEB-ADD-001 | Add to an empty cart | H | Logged in, empty cart | Add **Supreme** **Medium** | `Product added to the cart.`, counter 1 and item with quantity 1 | `@smoke @feature_cart` |
| TC-WEB-ADD-002 | Same company, another product | A | Item from `pizzeria` | Add **Pepperoni** | No warning, counter 2 and 2 items | `@feature_cart` |
| TC-WEB-ADD-003 | Same product and size | A | Logged in | Add **Double** twice | 1 item with quantity 2 and counter 2 | `@feature_cart` |
| TC-WEB-ADD-004 | Same product, another size | A | Logged in | Add **Orange** **Small** and **Large** | 2 items and counter 2 | `@feature_cart` |
| TC-WEB-ADD-005 | Add without logging in | E | No session | Click **Add to cart** | Login page with `Sign in to add products to the cart.` | `@smoke @feature_cart` |
| TC-WEB-ADD-006 | Quantity limit | E | **Double** item with quantity 99, through the API | Add **Double** | `Item quantity cannot exceed 99.` and quantity 99 kept | `@feature_cart` |
| TC-WEB-ADD-007 | API failure when adding | E | Add-item route responding 500 (mocked) | Add a product | Error message returned and counter unchanged | `@feature_cart` |
| TC-WEB-ADD-008 | Session of a non-existent user | E | `marketplace.user` in localStorage with an unregistered user | Add a product | `User not found.` | `@feature_cart` |

## 6. Company switch (BR-05 to BR-08, US-04)

| ID | Scenario | Type | Precondition | Steps | Expected result | Tags |
|---|---|---|---|---|---|---|
| TC-WEB-SWT-001 | Show the warning | H | Item from `pizzeria` | Add a product from `burgers` | Warning that the cart will be cleared, with **Yes** and **No** | `@smoke @feature_company_switch` |
| TC-WEB-SWT-002 | Confirming with Yes clears the cart | H | Item from `pizzeria` | Add **Double**; click **Yes**; open `/cart` | Cart with only **Double**, in the API and on the cart page. **Expected failure (BUG-01):** the cart keeps **Supreme** and receives **Double** | `@smoke @feature_company_switch @known_bug` |
| TC-WEB-SWT-003 | Declining with No | A | Item from `pizzeria` | Add **Double**; click **No** | Warning closed, cart and counter unchanged | `@smoke @feature_company_switch` |
| TC-WEB-SWT-004 | Close the warning with Esc | A | Item from `pizzeria` | Add **Double**; press Esc | Same effect as **No** | `@feature_company_switch` |
| TC-WEB-SWT-005 | Esc after a previous Yes | E | A **Yes** already happened in the session | Trigger a new warning; press Esc | The product is not added | `@feature_company_switch` |
| TC-WEB-SWT-006 | Counter after Yes | H | 1 unit from `pizzeria`; counter 1 | Add **Double**; click **Yes** | Counter 1. **Expected failure (BUG-01):** counter 2 | `@smoke @feature_company_switch @known_bug` |
| TC-WEB-SWT-007 | Counter after Yes with several units | A | 3 units from `pizzeria`; counter 3 | Add **Double**; click **Yes** | Counter 1. **Expected failure (BUG-01):** counter 4 | `@feature_company_switch @known_bug` |
| TC-WEB-SWT-008 | Counter after Yes and page reload | A | 1 unit from `pizzeria` | Add **Double**; click **Yes**; reload; open `/cart` | Counter 1 after reloading and on the cart page. **Expected failure (BUG-01):** counter 2 | `@feature_company_switch @known_bug` |
| TC-WEB-SWT-009 | Counter after Yes and another item from the same company | A | 1 unit from `pizzeria` | Add **Double**; click **Yes**; add **Classic** | No new warning and counter 2. **Expected failure (BUG-01):** the warning appears again, since **Supreme** is still in the cart | `@feature_company_switch @known_bug` |
| TC-WEB-SWT-010 | Counter matches the cart after Yes | A | 1 unit from `pizzeria` | Add **Double**; click **Yes**; open `/cart` | Counter equal to the sum of the quantities of the cart in the API, before and after opening `/cart` | `@feature_company_switch` |
| TC-WEB-SWT-011 | Counter after No with several units | A | 3 units from `pizzeria`; counter 3 | Add **Double**; click **No** | Warning closed and counter 3 | `@feature_company_switch` |

Scenario `TC-WEB-SWT-010` shows that the counter is updated and follows the real cart. Scenarios `TC-WEB-SWT-006` to `009` fail because the real cart is not cleared.

## 7. Cart (BR-04, BR-10 to BR-13, US-05)

| ID | Scenario | Type | Precondition | Steps | Expected result | Tags |
|---|---|---|---|---|---|---|
| TC-WEB-CRT-001 | Show item details | H | 1 **Supreme** **Medium** | Open `/cart` | Product, company, option, unit price `$52.90`, quantity 1, subtotal and total `$52.90` | `@smoke @feature_cart` |
| TC-WEB-CRT-002 | Empty cart | A | Logged in, no items | Open `/cart` | `Your cart is empty.` and **View companies** link | `@feature_cart` |
| TC-WEB-CRT-003 | Cart without logging in | E | No session | Open `/cart` | `Sign in to view your cart.` and **Sign in** button | `@feature_cart` |
| TC-WEB-CRT-004 | Update quantity | H | 1 item | Enter 3; click **Update** | Quantity 3. **Expected failure (BUG-02):** quantity 6 | `@smoke @feature_cart @known_bug` |
| TC-WEB-CRT-005 | Recalculate amounts | H | 1 **Supreme** **Medium** | Enter 3; click **Update** | Subtotal and total `$158.70`, counter 3. **Expected failure (BUG-02):** `$317.40` and counter 6 | `@feature_cart @known_bug` |
| TC-WEB-CRT-006 | Zero quantity | E | 1 item | Enter 0; **Update** | `Quantity must be an integer from 1 to 99.` and item unchanged | `@feature_cart` |
| TC-WEB-CRT-007 | Quantity above maximum | E | 1 item | Enter 100; **Update** | Same message and item unchanged | `@feature_cart` |
| TC-WEB-CRT-008 | Negative quantity | E | 1 item | Enter -1; **Update** | Same message and item unchanged | `@feature_cart` |
| TC-WEB-CRT-009 | Decimal quantity | E | 1 item | Enter 1.5; **Update** | Same message and item unchanged | `@feature_cart` |
| TC-WEB-CRT-010 | Empty quantity | E | 1 item | Clear the field; **Update** | Same message and item unchanged | `@feature_cart` |
| TC-WEB-CRT-011 | Remove one of several items | H | 2 items from the same company | **Remove** one item | Item removed, total and counter recalculated | `@smoke @feature_cart` |
| TC-WEB-CRT-012 | Remove the last item | A | 1 item | **Remove** | `Your cart is empty.` and counter 0 | `@feature_cart` |
| TC-WEB-CRT-013 | Independent carts | A | User A with an item; user B with no items | Sign in as B; open `/cart` | B's cart is empty | `@feature_cart` |
| TC-WEB-CRT-014 | Cart is kept | A | 1 item | Reload; sign out and sign in again | The item stays in the cart | `@feature_cart` |

## 8. Checkout (BR-14 to BR-16, US-06)

| ID | Scenario | Type | Precondition | Steps | Expected result | Tags |
|---|---|---|---|---|---|---|
| TC-WEB-CHK-001 | Check out a valid cart | H | Items from one company | Click **Checkout** | `Order confirmed` and **Pay** button | `@smoke @feature_checkout` |
| TC-WEB-CHK-002 | Different companies | E | Mixed cart, built through BUG-01 | Click **Checkout** | `The cart has items from different companies. The order cannot be completed.`, returned by the backend, without **Pay**. **Expected failure (BUG-03):** `Order confirmed` and **Pay** button shown | `@smoke @feature_checkout @known_bug` |
| TC-WEB-CHK-003 | Update after checking out | A | **Pay** button visible | Update the quantity | The **Pay** button is no longer shown | `@feature_checkout` |
| TC-WEB-CHK-004 | Remove after checking out | A | 2 items and **Pay** visible | Remove one item | The **Pay** button is no longer shown | `@feature_checkout` |
| TC-WEB-CHK-005 | Reload after checking out | A | **Pay** button visible | Reload | A new checkout is required; **Pay** does not appear | `@feature_checkout` |
| TC-WEB-CHK-006 | Pay before checking out | E | Cart with items | Open `/cart` | The **Pay** button is not shown | `@feature_checkout` |
| TC-WEB-CHK-007 | Empty cart | E | No items | Open `/cart` | **Checkout** and **Pay** are not shown | `@feature_checkout` |
| TC-WEB-CHK-008 | Cart emptied in another session | E | Cart page open; items removed through the API | Click **Checkout** | `The cart is empty.`, without **Pay** | `@feature_checkout` |

Scenario `TC-WEB-CHK-002` depends on BUG-01 to build its precondition. Once that defect is fixed, it will no longer be reachable through the UI.

## 9. Payment (BR-17, US-07)

| ID | Scenario | Type | Precondition | Steps | Expected result | Tags |
|---|---|---|---|---|---|---|
| TC-WEB-PAY-001 | Pay for the order | H | **Pay** button visible | Click **Pay** | `Fake payment completed` | `@smoke @feature_payment` |
| TC-WEB-PAY-002 | Cart after payment | H | Payment completed | Look at the screen | `Your cart is empty.` and counter 0 | `@smoke @feature_payment` |
| TC-WEB-PAY-003 | Cart emptied before paying | E | **Pay** visible; items removed through the API | Click **Pay** | `The cart is empty.` and **Pay** button removed | `@feature_payment` |
| TC-WEB-PAY-004 | API failure when paying | E | Payment route responding 500 (mocked) | Click **Pay** | Error message returned, without `Fake payment completed` | `@feature_payment` |
| TC-WEB-PAY-005 | Pay with different companies | E | **Pay** visible; mixed cart, built through BUG-01 | Click **Pay** | `The cart has items from different companies. The order cannot be completed.`, without `Fake payment completed`, items kept and **Pay** button removed | `@feature_payment` |

Scenario `TC-WEB-PAY-005` also depends on BUG-01 to build its precondition.

## 10. Running by tag

| Goal | Command |
|---|---|
| Web smoke | `npx playwright test --project=web-chromium --grep @smoke` |
| Login | `npx playwright test --project=web-chromium --grep @feature_login` |
| Cart | `npx playwright test --project=web-chromium --grep @feature_cart` |
| Company switch | `npx playwright test --project=web-chromium --grep @feature_company_switch` |
| Without known defects | `npx playwright test --project=web-chromium --grep-invert @known_bug` |
