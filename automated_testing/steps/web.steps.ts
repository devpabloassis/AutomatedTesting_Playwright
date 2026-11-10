// Steps for the Web scenarios.
import { expect } from '@playwright/test';
import { DataTable } from 'playwright-bdd';
import { MESSAGES, SESSION_KEY, uniqueName, VALID_PASSWORD } from '../support/data';
import { Given, Then, When } from '../support/fixtures';
import { required } from './common.steps';

// Cart item reference in the "product/option" format, for example "supreme/M".
const cartItem = (reference: string) => reference.split('/') as [string, string];

// Seeds the session only on the first load of the tab, so that "Sign out" keeps working afterwards.
async function seedSession(page: import('@playwright/test').Page, username: string) {
  await page.addInitScript(
    ([key, value]) => {
      if (sessionStorage.getItem('session-seeded')) return;
      localStorage.setItem(key, value);
      sessionStorage.setItem('session-seeded', '1');
    },
    [SESSION_KEY, username],
  );
}

// Session and setup

Given('I am logged in as a new user', async ({ api, world, page }) => {
  world.username = await api.newUser();
  await seedSession(page, world.username);
});

Given('I am not logged in', async () => {});

Given('the browser session belongs to a non-existent user', async ({ page }) => {
  await seedSession(page, uniqueName());
});

Given('the API responds with a 500 error on {string}', async ({ page }, pattern: string) => {
  await page.route(pattern, (route) =>
    route.fulfill({ status: 500, json: { code: 'INTERNAL_ERROR', message: MESSAGES.internalError } }),
  );
});

Given('the screen is {int} pixels wide', async ({ page }, width: number) => {
  await page.setViewportSize({ width, height: 700 });
});

Given('I am monitoring login requests', async ({ page, world }) => {
  page.on('request', (request) => {
    if (request.url().includes('/api/login')) world.loginRequests.push(request.url());
  });
});

// Navigation

Given('I am on the page {string}', async ({ page }, path: string) => {
  await page.goto(path);
});

When('I open the page {string}', async ({ page }, path: string) => {
  await page.goto(path);
});

When('I reload the page', async ({ page }) => {
  await page.reload();
});

When('I go back in the browser', async ({ page }) => {
  await page.goBack();
});

When('I click the header brand', async ({ header }) => {
  await header.brand.click();
});

When('I click the company {string}', async ({ homePage }, companyId: string) => {
  await homePage.company(companyId).click();
});

When('I navigate through the site to the company {string}', async ({ header, homePage, companyPage }, companyId: string) => {
  await header.brand.click();
  await homePage.company(companyId).click();
  await expect(companyPage.products.first()).toBeVisible();
});

Then('I should be on the page {string}', async ({ page }, path: string) => {
  await expect(page).toHaveURL(path);
});

Then('I should be on the login page', async ({ page, loginPage }) => {
  await expect(page).toHaveURL(/\/login/);
  await expect(loginPage.username).toBeVisible();
});

Then('I should stay on the system', async ({ page, baseURL }) => {
  expect(new URL(page.url()).origin).toBe(new URL(baseURL!).origin);
});

Then('the page title should be {string}', async ({ homePage }, title: string) => {
  await expect(homePage.title).toHaveText(title);
});

Then('I should see the link back to the companies', async ({ companyPage }) => {
  await expect(companyPage.backToCompanies).toBeVisible();
});

Then('I should see {int} companies', async ({ homePage }, count: number) => {
  await expect(homePage.companies).toHaveCount(count);
});

Then('I should see {int} products', async ({ companyPage }, count: number) => {
  await expect(companyPage.products).toHaveCount(count);
});

Then(
  'each company below should open from the home page with {int} products:',
  async ({ page, homePage, companyPage }, count: number, table: DataTable) => {
    for (const [companyId] of table.raw()) {
      await homePage.open();
      await homePage.company(companyId).click();
      await expect(page).toHaveURL(`/companies/${companyId}`);
      await expect(companyPage.products).toHaveCount(count);
    }
  },
);

Then('the page should not scroll horizontally', async ({ page }) => {
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
});

// Messages and header

Then('I should see the message {string}', async ({ header }, message: string) => {
  await expect(header.message).toHaveText(message);
});

Then('the message {string} should not appear', async ({ page }, message: string) => {
  await expect(page.getByText(message, { exact: true })).toHaveCount(0);
});

Then('the cart counter should show {string}', async ({ header }, value: string) => {
  await expect(header.cartCount).toHaveText(value);
});

// Compares the counter with the sum of the quantities in the cart stored by the API.
Then("the cart counter should match the user's cart", async ({ api, header, world }) => {
  const cart = await api.cart(required(world.username, 'the user'));
  await expect(header.cartCount).toHaveText(String(cart.totalItems));
});

Then('I should see the Sign in link in the header', async ({ header }) => {
  await expect(header.loginLink).toBeVisible();
});

Then('I should see the created user in the header', async ({ header, world }) => {
  await expect(header.loggedUser).toHaveText(required(world.username, 'the user'));
});

Then('I should see the Sign out button', async ({ header }) => {
  await expect(header.logout).toBeVisible();
});

Then('I should not be logged in', async ({ header }) => {
  await expect(header.loggedUser).toHaveCount(0);
});

When('I click Sign out', async ({ header }) => {
  await header.logout.click();
});

// Login

When('I log in with the created user', async ({ loginPage, world }) => {
  await loginPage.login(required(world.username, 'the user'), VALID_PASSWORD);
});

When(
  'I log in with the username {string} and the password {string}',
  async ({ loginPage }, username: string, password: string) => {
    await loginPage.login(username, password);
  },
);

When('I log in with a non-existent user and the password {string}', async ({ loginPage }, password: string) => {
  await loginPage.login(uniqueName(), password);
});

When('I click Sign in without filling in the fields', async ({ loginPage }) => {
  await loginPage.submit.click();
});

Then('the username field should be focused', async ({ loginPage }) => {
  await expect(loginPage.username).toBeFocused();
});

Then('no login request should have been sent', async ({ world }) => {
  expect(world.loginRequests).toEqual([]);
});

Then(
  'each user below should be able to sign in and sign out with the password {string}:',
  async ({ loginPage, header }, password: string, table: DataTable) => {
    for (const [username] of table.raw()) {
      await loginPage.open();
      await loginPage.login(username, password);
      await expect(header.loggedUser).toHaveText(username);
      await header.logout.click();
      await expect(header.loginLink).toBeVisible();
    }
  },
);

// Products

When('I select the size {string} for the product {string}', async ({ companyPage }, size: string, productId: string) => {
  await companyPage.selectSize(productId, size);
});

When('I add the product {string} to the cart', async ({ companyPage }, productId: string) => {
  await companyPage.add(productId);
});

Then(
  'the selected size of the product {string} should be {string}',
  async ({ companyPage }, productId: string, optionId: string) => {
    await expect(companyPage.size(productId)).toHaveValue(optionId);
  },
);

Then('the price of the product {string} should be {string}', async ({ companyPage }, productId: string, price: string) => {
  await expect(companyPage.price(productId)).toHaveText(price);
});

Then('the product {string} should not have a size selector', async ({ companyPage }, productId: string) => {
  await expect(companyPage.product(productId)).toBeVisible();
  await expect(companyPage.size(productId)).toHaveCount(0);
});

// Company switch warning

Then('the company switch warning should show the text {string}', async ({ companyPage }, text: string) => {
  await expect(companyPage.dialogText).toContainText(text);
});

Then('the company switch warning should have the Yes and No options', async ({ companyPage }) => {
  await expect(companyPage.dialogYes).toBeVisible();
  await expect(companyPage.dialogNo).toBeVisible();
});

Then('the company switch warning should be visible', async ({ companyPage }) => {
  await expect(companyPage.dialog).toBeVisible();
});

Then('the company switch warning should not be visible', async ({ companyPage }) => {
  await expect(companyPage.dialog).toBeHidden();
});

When('I answer the company switch warning with {string}', async ({ companyPage }, answer: string) => {
  await (answer === 'Yes' ? companyPage.dialogYes : companyPage.dialogNo).click();
});

When('I close the warning with the Esc key', async ({ companyPage, page }) => {
  await expect(companyPage.dialog).toBeVisible();
  await page.keyboard.press('Escape');
});

// Cart

When('I change the quantity of the item {string} to {string}', async ({ cartPage }, reference: string, value: string) => {
  await cartPage.updateQuantity(...cartItem(reference), value);
});

When('I remove the item {string}', async ({ cartPage }, reference: string) => {
  await cartPage.remove(...cartItem(reference));
});

When('I check out', async ({ cartPage }) => {
  await cartPage.checkout.click();
});

When('I click Pay', async ({ cartPage }) => {
  await cartPage.pay.click();
});

When("I click the cart's Sign in button", async ({ cartPage }) => {
  await cartPage.loginButton.click();
});

Then('the row of the item {string} should show:', async ({ cartPage }, reference: string, table: DataTable) => {
  for (const [text] of table.raw()) await expect(cartPage.row(...cartItem(reference))).toContainText(text);
});

Then('I should see the item {string} in the cart', async ({ cartPage }, reference: string) => {
  await expect(cartPage.row(...cartItem(reference))).toBeVisible();
});

Then('the item {string} should not be in the cart', async ({ cartPage }, reference: string) => {
  await expect(cartPage.row(...cartItem(reference))).toHaveCount(0);
});

Then(
  'the on-screen quantity of the item {string} should be {string}',
  async ({ cartPage }, reference: string, value: string) => {
    await expect(cartPage.quantity(...cartItem(reference))).toHaveValue(value);
  },
);

Then('the subtotal of the item {string} should be {string}', async ({ cartPage }, reference: string, value: string) => {
  await expect(cartPage.subtotal(...cartItem(reference))).toHaveText(value);
});

Then('the cart total should be {string}', async ({ cartPage }, value: string) => {
  await expect(cartPage.total).toHaveText(value);
});

Then('the cart total should no longer be {string}', async ({ cartPage }, value: string) => {
  await expect(cartPage.total).not.toHaveText(value);
});

Then('I should see the empty cart notice', async ({ cartPage }) => {
  await expect(cartPage.emptyMessage).toHaveText(MESSAGES.emptyCart);
});

Then('I should see the View companies link', async ({ cartPage }) => {
  await expect(cartPage.viewCompanies).toBeVisible();
});

Then('I should see the cart sign-in notice {string}', async ({ cartPage }, message: string) => {
  await expect(cartPage.loginMessage).toHaveText(message);
});

Then("I should see the cart's Sign in button", async ({ cartPage }) => {
  await expect(cartPage.loginButton).toBeVisible();
});

Then('the Pay button should be visible', async ({ cartPage }) => {
  await expect(cartPage.pay).toBeVisible();
});

Then('the Pay button should not be visible', async ({ cartPage }) => {
  await expect(cartPage.pay).toHaveCount(0);
});

Then('the Checkout button should be visible', async ({ cartPage }) => {
  await expect(cartPage.checkout).toBeVisible();
});

Then('the Checkout button should not be visible', async ({ cartPage }) => {
  await expect(cartPage.checkout).toHaveCount(0);
});
