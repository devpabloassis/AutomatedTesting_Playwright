// Steps for the API scenarios.
import { randomInt } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { expect } from '@playwright/test';
import { DataTable } from 'playwright-bdd';
import { MarketApi } from '../support/api/market-api';
import { contractViolations } from '../support/contract';
import { SEED_USERS, uniqueName } from '../support/data';
import { Given, Then, When, World } from '../support/fixtures';
import { IsolatedServer } from '../support/isolated-server';
import { required } from './common.steps';

const SENSITIVE_FIELDS = ['password', 'salt', 'hash'];
const PLACEHOLDER = /\{([a-z0-9_]+)\}/g;

const randomFrom = (alphabet: string) =>
  Array.from({ length: 20 }, () => alphabet[randomInt(alphabet.length)]).join('');

async function freeUnderscoreName(api: MarketApi): Promise<string> {
  for (let length = 3; length <= 30; length++) {
    const name = '_'.repeat(length);
    if ((await api.getUser(name)).status() === 404) return name;
  }
  throw new Error('Reset the test database: every underscore-only name has already been created.');
}

// {name} placeholders used in the request paths and bodies of the .feature files.
async function placeholderValue(key: string, api: MarketApi, world: World): Promise<string> {
  switch (key) {
    case 'user':
      return required(world.username, 'the user');
    case 'other_user':
      return required(world.otherUsername, 'the other user');
    case 'item':
      return required(world.itemId, 'the item');
    case 'other_item':
      return required(world.otherItemId, "the other user's item");
    case 'payload':
      return required(world.payload, 'the payload');
    case 'unique_name':
      return (world.generatedName = uniqueName());
    case 'generated_name':
      return required(world.generatedName, 'a generated name');
    case 'name_3_chars':
      return uniqueName().slice(-3);
    case 'name_30_chars':
      return uniqueName().padEnd(30, 'x');
    case 'unique_lowercase':
      return randomFrom('abcdefghijklmnopqrstuvwxyz');
    case 'unique_uppercase':
      return randomFrom('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    case 'unique_digits':
      return randomFrom('0123456789');
    case 'unique_mix':
      return `Ab_12${randomFrom('abc123')}`;
    case 'free_underscores':
      return freeUnderscoreName(api);
    case 'unique_password':
      return (world.generatedPassword = `secret${uniqueName()}`);
    default:
      throw new Error(`Unknown placeholder: {${key}}`);
  }
}

async function resolve(text: string, api: MarketApi, world: World, mode: 'path' | 'body') {
  const values = new Map<string, string>();
  for (const [, key] of text.matchAll(PLACEHOLDER)) {
    if (!values.has(key)) values.set(key, await placeholderValue(key, api, world));
  }
  return text.replace(PLACEHOLDER, (_, key: string) => {
    const value = values.get(key)!;
    return mode === 'path' ? encodeURIComponent(value) : JSON.stringify(value).slice(1, -1);
  });
}

function parseJson(text: string | undefined) {
  if (text === undefined) return undefined;
  try {
    return JSON.parse(text);
  } catch {
    return undefined;
  }
}

async function send(api: MarketApi, world: World, method: string, path: string, rawBody?: string) {
  const resolvedPath = await resolve(path, api, world, 'path');
  const body = rawBody === undefined ? undefined : await resolve(rawBody, api, world, 'body');
  world.lastBody = parseJson(body);
  const response = await api.send(method, `${world.server?.url ?? '/api'}${resolvedPath}`, body);
  const text = await response.text();
  world.response = { status: response.status(), headers: response.headers(), text, json: parseJson(text) };
}

const lastResponse = (world: World) => required(world.response, 'a response');

// Requests

When('I send {string} to {string}', async ({ api, world }, method: string, path: string) => {
  await send(api, world, method, path);
});

When('I send {string} to {string} without a body', async ({ api, world }, method: string, path: string) => {
  await send(api, world, method, path);
});

When(
  'I send {string} to {string} with the body:',
  async ({ api, world }, method: string, path: string, body: string) => {
    await send(api, world, method, path, body);
  },
);

When(
  'I send {string} to {string} with a {int} KB password',
  async ({ api, world }, method: string, path: string, kilobytes: number) => {
    const body = JSON.stringify({ username: uniqueName(), password: 'x'.repeat(kilobytes * 1024) });
    await send(api, world, method, path, body);
  },
);

// Responses

Then('the response status should be {int}', async ({ world }, status: number) => {
  expect(lastResponse(world).status).toBe(status);
});

Then('the response should be a {int} error with code {string}', async ({ world }, status: number, code: string) => {
  const response = lastResponse(world);
  expect(response.status).toBe(status);
  expect(response.json?.code).toBe(code);
});

Then('the error message should be {string}', async ({ world }, message: string) => {
  expect(lastResponse(world).json?.message).toBe(message);
});

Then('the response should contain:', async ({ api, world }, expected: string) => {
  expect(lastResponse(world).json).toMatchObject(JSON.parse(await resolve(expected, api, world, 'body')));
});

Then('the response should be exactly:', async ({ api, world }, expected: string) => {
  expect(lastResponse(world).json).toEqual(JSON.parse(await resolve(expected, api, world, 'body')));
});

Then('the response should follow the {string} contract', async ({ world }, contract: string) => {
  const violations = contractViolations(contract, lastResponse(world).json);
  expect(violations, `The response does not follow the "${contract}" contract`).toEqual([]);
});

Then('the response should be a {int} error that follows the contract', async ({ world }, status: number) => {
  const response = lastResponse(world);
  expect(response.status).toBe(status);
  expect(contractViolations('error', response.json), 'The response does not follow the "error" contract').toEqual([]);
});

Then('the response should have the creation date', async ({ world }) => {
  expect(lastResponse(world).json?.createdAt).toBeTruthy();
});

Then('the response should not contain password data', async ({ world }) => {
  for (const field of SENSITIVE_FIELDS) expect(lastResponse(world).json).not.toHaveProperty(field);
});

Then('the response should not contain the payload', async ({ world }) => {
  const escaped = JSON.stringify(required(world.payload, 'the payload')).slice(1, -1);
  expect(lastResponse(world).text).not.toContain(escaped);
});

Then('the returned cart should have {int} item(s)', async ({ world }, count: number) => {
  expect(lastResponse(world).json?.items).toHaveLength(count);
});

Then('the returned cart should contain only the products {string}', async ({ world }, products: string) => {
  const items: { productId: string }[] = lastResponse(world).json?.items ?? [];
  expect(items.map((item) => item.productId)).toEqual(products.split(',').map((product) => product.trim()));
});

Then('the response header {string} should contain {string}', async ({ world }, name: string, value: string) => {
  expect(lastResponse(world).headers[name.toLowerCase()]).toContain(value);
});

Then('logging in with the sent credentials should return status {int}', async ({ api, world }, status: number) => {
  const { username, password } = required(world.lastBody, 'the sent body');
  expect((await api.login({ username, password })).status()).toBe(status);
});

// Catalog

Then(
  'the response should have {int} companies with {int} products each',
  async ({ world }, companies: number, products: number) => {
    const body = lastResponse(world).json;
    expect(body).toHaveLength(companies);
    for (const company of body) expect(company.products).toHaveLength(products);
  },
);

Then('the catalog prices in cents should be:', async ({ api }, table: DataTable) => {
  const companies: any[] = await (await api.getCompanies()).json();
  for (const { company, product, prices } of table.hashes()) {
    const found = companies.find((candidate) => candidate.id === company)?.products.find((p: any) => p.id === product);
    const actual = found?.options.map((option: { priceCents: number }) => option.priceCents);
    expect(actual, `${company}/${product}`).toEqual(prices.split(',').map(Number));
  }
});

Then('each company below should be returned when fetched by its id:', async ({ api }, table: DataTable) => {
  for (const [companyId] of table.raw()) {
    const response = await api.getCompany(companyId);
    expect(response.status()).toBe(200);
    expect((await response.json()).id).toBe(companyId);
  }
});

Then(
  'the products of the companies {string} should have the options {string}',
  async ({ api }, companies: string, options: string) => {
    const expected = options.split(',').map((option) => option.trim());
    for (const companyId of companies.split(',').map((company) => company.trim())) {
      const { products } = await (await api.getCompany(companyId)).json();
      for (const product of products) {
        expect(product.options.map((option: { id: string }) => option.id), product.id).toEqual(expected);
      }
    }
  },
);

// Seed users

Then('each user below should be found:', async ({ api }, table: DataTable) => {
  for (const [username] of table.raw()) {
    const response = await api.getUser(username);
    expect(response.status(), username).toBe(200);
    expect((await response.json()).username).toBe(username);
  }
});

Then(
  'each user below should be able to log in with the password {string}:',
  async ({ api }, password: string, table: DataTable) => {
    for (const [username] of table.raw()) {
      expect((await api.login({ username, password })).status(), username).toBe(200);
    }
  },
);

// SQL injection

Given('the SQL injection payload:', async ({ world }, payload: string) => {
  world.payload = payload;
});

// Persistence

Given('I am using an isolated server', async ({ world, $testInfo }) => {
  world.server = new IsolatedServer(3200 + $testInfo.parallelIndex, $testInfo.outputPath('db.json'));
  await world.server.start();
});

When('I restart the server', async ({ world }) => {
  await required(world.server, 'the isolated server').restart();
});

async function seedCreatedAt(api: MarketApi, server: IsolatedServer) {
  return Promise.all(
    SEED_USERS.map(async (username) => (await (await api.send('GET', `${server.url}/users/${username}`)).json()).createdAt),
  );
}

Given('I save the creation date of the seed users', async ({ api, world }) => {
  world.seedCreatedAt = await seedCreatedAt(api, required(world.server, 'the isolated server'));
});

Then('the creation date of the seed users should be unchanged', async ({ api, world }) => {
  const current = await seedCreatedAt(api, required(world.server, 'the isolated server'));
  expect(current).toEqual(required(world.seedCreatedAt, 'the saved dates'));
});

Then('each seed user should appear only once in the database', async ({ world }) => {
  const { users } = JSON.parse(readFileSync(required(world.server, 'the isolated server').dbPath, 'utf8'));
  for (const username of SEED_USERS) {
    expect(users.filter((user: { username: string }) => user.username === username), username).toHaveLength(1);
  }
});

Then('the database file should not contain the sent password', async ({ world }) => {
  const database = readFileSync(required(world.server, 'the isolated server').dbPath, 'utf8');
  expect(database).not.toContain(required(world.generatedPassword, 'the generated password'));
});
