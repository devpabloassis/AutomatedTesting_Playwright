// Steps shared by the API and Web scenarios.
import { expect } from '@playwright/test';
import { MarketApi } from '../support/api/market-api';
import { BURGER, PIZZA } from '../support/data';
import { Given, Then, When, World } from '../support/fixtures';

// Item reference in the "company/product/option" format, for example "pizzeria/supreme/M".
export function parseItem(reference: string) {
  const [companyId, productId, optionId] = reference.split('/');
  return { companyId, productId, optionId };
}

export function required<T>(value: T | undefined, description: string): T {
  if (value === undefined) throw new Error(`The scenario has not defined ${description} yet.`);
  return value;
}

const productList = (text: string) => text.split(',').map((product) => product.trim());

async function seedItem(api: MarketApi, world: World, reference: string, quantity: number) {
  const item = parseItem(reference);
  const cart = await api.seedItem(required(world.username, 'the user'), { ...item, quantity });
  world.itemId ??= cart.items.find(
    (candidate) => candidate.productId === item.productId && candidate.optionId === item.optionId,
  )?.id;
}

Given('a new user exists', async ({ api, world }) => {
  world.username = await api.newUser();
});

Given('another new user exists with the item {string}', async ({ api, world }, reference: string) => {
  world.otherUsername = await api.newUser();
  const cart = await api.seedItem(world.otherUsername, parseItem(reference));
  world.otherItemId = cart.items[0].id;
});

Given("the user's cart has the item {string}", async ({ api, world }, reference: string) => {
  await seedItem(api, world, reference, 1);
});

Given(
  "the user's cart has the item {string} with quantity {int}",
  async ({ api, world }, reference: string, quantity: number) => {
    await seedItem(api, world, reference, quantity);
  },
);

// This cart can only be built because of BUG-01.
Given("the user's cart has items from different companies", async ({ api, world }) => {
  const username = required(world.username, 'the user');
  const cart = await api.seedItem(username, PIZZA);
  world.itemId ??= cart.items[0].id;
  await api.seedItem(username, { ...BURGER, replaceCart: true });
});

When('the cart is emptied in another session', async ({ api, world }) => {
  await api.emptyCart(required(world.username, 'the user'));
});

When(
  'the cart receives the item {string} with a company switch in another session',
  async ({ api, world }, reference: string) => {
    await api.seedItem(required(world.username, 'the user'), { ...parseItem(reference), replaceCart: true });
  },
);

When('I save the cart state', async ({ api, world }) => {
  world.cartSnapshot = await api.cart(required(world.username, 'the user'));
});

Then("the user's cart should have {int} item(s)", async ({ api, world }, count: number) => {
  expect((await api.cart(required(world.username, 'the user'))).items).toHaveLength(count);
});

Then("the user's cart should contain only the products {string}", async ({ api, world }, products: string) => {
  const cart = await api.cart(required(world.username, 'the user'));
  expect(cart.items.map((item) => item.productId)).toEqual(productList(products));
});

Then(
  "the user's cart should contain the item {string} with quantity {int}",
  async ({ api, world }, reference: string, quantity: number) => {
    const cart = await api.cart(required(world.username, 'the user'));
    expect(cart.items).toContainEqual(expect.objectContaining({ ...parseItem(reference), quantity }));
  },
);

Then('the item quantity in the cart should be {int}', async ({ api, world }, quantity: number) => {
  const cart = await api.cart(required(world.username, 'the user'));
  const item = cart.items.find((candidate) => candidate.id === required(world.itemId, 'the item'));
  expect(item?.quantity).toBe(quantity);
});

Then("the other user's cart should have {int} item(s)", async ({ api, world }, count: number) => {
  expect((await api.cart(required(world.otherUsername, 'the other user'))).items).toHaveLength(count);
});

Then("the other user's item quantity should be {int}", async ({ api, world }, quantity: number) => {
  const cart = await api.cart(required(world.otherUsername, 'the other user'));
  expect(cart.items.find((item) => item.id === world.otherItemId)?.quantity).toBe(quantity);
});

Then("the user's cart should not have changed", async ({ api, world }) => {
  const cart = await api.cart(required(world.username, 'the user'));
  expect(cart).toEqual(required(world.cartSnapshot, 'the saved cart state'));
});
