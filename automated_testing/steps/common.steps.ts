// Passos usados tanto nos cenários de API quanto nos cenários Web.
import { expect } from '@playwright/test';
import { MarketApi } from '../support/api/market-api';
import { BURGER, PIZZA } from '../support/data';
import { Given, Then, When, World } from '../support/fixtures';

// Referência de item no formato "empresa/produto/opção", por exemplo "pizzaria/portuguesa/M".
export function parseItem(reference: string) {
  const [companyId, productId, optionId] = reference.split('/');
  return { companyId, productId, optionId };
}

export function required<T>(value: T | undefined, description: string): T {
  if (value === undefined) throw new Error(`O cenário ainda não definiu ${description}.`);
  return value;
}

const productList = (text: string) => text.split(',').map((product) => product.trim());

async function seedItem(api: MarketApi, world: World, reference: string, quantity: number) {
  const item = parseItem(reference);
  const cart = await api.seedItem(required(world.username, 'o usuário'), { ...item, quantity });
  world.itemId ??= cart.items.find(
    (candidate) => candidate.productId === item.productId && candidate.optionId === item.optionId,
  )?.id;
}

Given('que existe um usuário novo', async ({ api, world }) => {
  world.username = await api.newUser();
});

Given('que existe outro usuário novo com o item {string}', async ({ api, world }, reference: string) => {
  world.otherUsername = await api.newUser();
  const cart = await api.seedItem(world.otherUsername, parseItem(reference));
  world.otherItemId = cart.items[0].id;
});

Given('que o carrinho do usuário tem o item {string}', async ({ api, world }, reference: string) => {
  await seedItem(api, world, reference, 1);
});

Given(
  'que o carrinho do usuário tem o item {string} com quantidade {int}',
  async ({ api, world }, reference: string, quantity: number) => {
    await seedItem(api, world, reference, quantity);
  },
);

// Só é possível montar este carrinho por causa do BUG-01.
Given('que o carrinho do usuário tem itens de empresas diferentes', async ({ api, world }) => {
  const username = required(world.username, 'o usuário');
  const cart = await api.seedItem(username, PIZZA);
  world.itemId ??= cart.items[0].id;
  await api.seedItem(username, { ...BURGER, replaceCart: true });
});

When('o carrinho é esvaziado em outra sessão', async ({ api, world }) => {
  await api.emptyCart(required(world.username, 'o usuário'));
});

When(
  'o carrinho recebe em outra sessão o item {string} com troca de empresa',
  async ({ api, world }, reference: string) => {
    await api.seedItem(required(world.username, 'o usuário'), { ...parseItem(reference), replaceCart: true });
  },
);

When('guardo o estado do carrinho', async ({ api, world }) => {
  world.cartSnapshot = await api.cart(required(world.username, 'o usuário'));
});

Then('o carrinho do usuário deve ter {int} item/itens', async ({ api, world }, count: number) => {
  expect((await api.cart(required(world.username, 'o usuário'))).items).toHaveLength(count);
});

Then('o carrinho do usuário deve conter somente os produtos {string}', async ({ api, world }, products: string) => {
  const cart = await api.cart(required(world.username, 'o usuário'));
  expect(cart.items.map((item) => item.productId)).toEqual(productList(products));
});

Then(
  'o carrinho do usuário deve conter o item {string} com quantidade {int}',
  async ({ api, world }, reference: string, quantity: number) => {
    const cart = await api.cart(required(world.username, 'o usuário'));
    expect(cart.items).toContainEqual(expect.objectContaining({ ...parseItem(reference), quantity }));
  },
);

Then('a quantidade do item no carrinho deve ser {int}', async ({ api, world }, quantity: number) => {
  const cart = await api.cart(required(world.username, 'o usuário'));
  const item = cart.items.find((candidate) => candidate.id === required(world.itemId, 'o item'));
  expect(item?.quantity).toBe(quantity);
});

Then('o carrinho do outro usuário deve ter {int} item/itens', async ({ api, world }, count: number) => {
  expect((await api.cart(required(world.otherUsername, 'o outro usuário'))).items).toHaveLength(count);
});

Then('a quantidade do item do outro usuário deve ser {int}', async ({ api, world }, quantity: number) => {
  const cart = await api.cart(required(world.otherUsername, 'o outro usuário'));
  expect(cart.items.find((item) => item.id === world.otherItemId)?.quantity).toBe(quantity);
});

Then('o carrinho do usuário não deve ter mudado', async ({ api, world }) => {
  const cart = await api.cart(required(world.username, 'o usuário'));
  expect(cart).toEqual(required(world.cartSnapshot, 'o estado guardado do carrinho'));
});
