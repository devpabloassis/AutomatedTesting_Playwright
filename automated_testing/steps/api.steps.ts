// Passos dos cenários de API.
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
  throw new Error('Reinicie o banco de testes: todos os nomes só com _ já foram criados.');
}

// Marcadores {nome} usados nos caminhos e corpos das requisições dos arquivos .feature.
async function placeholderValue(key: string, api: MarketApi, world: World): Promise<string> {
  switch (key) {
    case 'usuario':
      return required(world.username, 'o usuário');
    case 'outro_usuario':
      return required(world.otherUsername, 'o outro usuário');
    case 'item':
      return required(world.itemId, 'o item');
    case 'item_do_outro':
      return required(world.otherItemId, 'o item do outro usuário');
    case 'payload':
      return required(world.payload, 'o payload');
    case 'nome_unico':
      return (world.generatedName = uniqueName());
    case 'nome_gerado':
      return required(world.generatedName, 'um nome gerado');
    case 'nome_3_caracteres':
      return uniqueName().slice(-3);
    case 'nome_30_caracteres':
      return uniqueName().padEnd(30, 'x');
    case 'minusculas_unico':
      return randomFrom('abcdefghijklmnopqrstuvwxyz');
    case 'maiusculas_unico':
      return randomFrom('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    case 'numeros_unico':
      return randomFrom('0123456789');
    case 'combinacao_unica':
      return `Ab_12${randomFrom('abc123')}`;
    case 'sublinhados_livre':
      return freeUnderscoreName(api);
    case 'senha_unica':
      return (world.generatedPassword = `segredo${uniqueName()}`);
    default:
      throw new Error(`Marcador desconhecido: {${key}}`);
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

const lastResponse = (world: World) => required(world.response, 'uma resposta');

// Requisições

When('envio {string} para {string}', async ({ api, world }, method: string, path: string) => {
  await send(api, world, method, path);
});

When('envio {string} para {string} sem corpo', async ({ api, world }, method: string, path: string) => {
  await send(api, world, method, path);
});

When(
  'envio {string} para {string} com o corpo:',
  async ({ api, world }, method: string, path: string, body: string) => {
    await send(api, world, method, path, body);
  },
);

When(
  'envio {string} para {string} com uma senha de {int} KB',
  async ({ api, world }, method: string, path: string, kilobytes: number) => {
    const body = JSON.stringify({ username: uniqueName(), password: 'x'.repeat(kilobytes * 1024) });
    await send(api, world, method, path, body);
  },
);

// Respostas

Then('o status da resposta deve ser {int}', async ({ world }, status: number) => {
  expect(lastResponse(world).status).toBe(status);
});

Then('a resposta deve ser um erro {int} com o código {string}', async ({ world }, status: number, code: string) => {
  const response = lastResponse(world);
  expect(response.status).toBe(status);
  expect(response.json?.code).toBe(code);
});

Then('a mensagem de erro deve ser {string}', async ({ world }, message: string) => {
  expect(lastResponse(world).json?.message).toBe(message);
});

Then('a resposta deve conter:', async ({ api, world }, expected: string) => {
  expect(lastResponse(world).json).toMatchObject(JSON.parse(await resolve(expected, api, world, 'body')));
});

Then('a resposta deve ser exatamente:', async ({ api, world }, expected: string) => {
  expect(lastResponse(world).json).toEqual(JSON.parse(await resolve(expected, api, world, 'body')));
});

Then('a resposta deve seguir o contrato {string}', async ({ world }, contract: string) => {
  const violations = contractViolations(contract, lastResponse(world).json);
  expect(violations, `A resposta não segue o contrato "${contract}"`).toEqual([]);
});

Then('a resposta deve ser um erro {int} que segue o contrato', async ({ world }, status: number) => {
  const response = lastResponse(world);
  expect(response.status).toBe(status);
  expect(contractViolations('error', response.json), 'A resposta não segue o contrato "error"').toEqual([]);
});

Then('a resposta deve ter a data de criação', async ({ world }) => {
  expect(lastResponse(world).json?.createdAt).toBeTruthy();
});

Then('a resposta não deve conter dados de senha', async ({ world }) => {
  for (const field of SENSITIVE_FIELDS) expect(lastResponse(world).json).not.toHaveProperty(field);
});

Then('a resposta não deve conter o payload', async ({ world }) => {
  const escaped = JSON.stringify(required(world.payload, 'o payload')).slice(1, -1);
  expect(lastResponse(world).text).not.toContain(escaped);
});

Then('o carrinho retornado deve ter {int} item/itens', async ({ world }, count: number) => {
  expect(lastResponse(world).json?.items).toHaveLength(count);
});

Then('o carrinho retornado deve conter somente os produtos {string}', async ({ world }, products: string) => {
  const items: { productId: string }[] = lastResponse(world).json?.items ?? [];
  expect(items.map((item) => item.productId)).toEqual(products.split(',').map((product) => product.trim()));
});

Then('o cabeçalho {string} da resposta deve conter {string}', async ({ world }, name: string, value: string) => {
  expect(lastResponse(world).headers[name.toLowerCase()]).toContain(value);
});

Then('o login com as credenciais enviadas deve ter status {int}', async ({ api, world }, status: number) => {
  const { username, password } = required(world.lastBody, 'o corpo enviado');
  expect((await api.login({ username, password })).status()).toBe(status);
});

// Catálogo

Then(
  'a resposta deve ter {int} empresas com {int} produtos cada',
  async ({ world }, companies: number, products: number) => {
    const body = lastResponse(world).json;
    expect(body).toHaveLength(companies);
    for (const company of body) expect(company.products).toHaveLength(products);
  },
);

Then('os preços do catálogo em centavos devem ser:', async ({ api }, table: DataTable) => {
  const companies: any[] = await (await api.getCompanies()).json();
  for (const { empresa, produto, precos } of table.hashes()) {
    const product = companies.find((company) => company.id === empresa)?.products.find((p: any) => p.id === produto);
    const prices = product?.options.map((option: { priceCents: number }) => option.priceCents);
    expect(prices, `${empresa}/${produto}`).toEqual(precos.split(',').map(Number));
  }
});

Then('cada empresa abaixo deve ser retornada na consulta pelo seu id:', async ({ api }, table: DataTable) => {
  for (const [companyId] of table.raw()) {
    const response = await api.getCompany(companyId);
    expect(response.status()).toBe(200);
    expect((await response.json()).id).toBe(companyId);
  }
});

Then(
  'os produtos das empresas {string} devem ter as opções {string}',
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

// Usuários pré-cadastrados

Then('cada usuário abaixo deve ser encontrado na consulta:', async ({ api }, table: DataTable) => {
  for (const [username] of table.raw()) {
    const response = await api.getUser(username);
    expect(response.status(), username).toBe(200);
    expect((await response.json()).username).toBe(username);
  }
});

Then(
  'cada usuário abaixo deve conseguir fazer login com a senha {string}:',
  async ({ api }, password: string, table: DataTable) => {
    for (const [username] of table.raw()) {
      expect((await api.login({ username, password })).status(), username).toBe(200);
    }
  },
);

// SQL injection

Given('o payload de SQL injection:', async ({ world }, payload: string) => {
  world.payload = payload;
});

// Persistência

Given('que estou usando um servidor isolado', async ({ world, $testInfo }) => {
  world.server = new IsolatedServer(3200 + $testInfo.parallelIndex, $testInfo.outputPath('db.json'));
  await world.server.start();
});

When('reinicio o servidor', async ({ world }) => {
  await required(world.server, 'o servidor isolado').restart();
});

async function seedCreatedAt(api: MarketApi, server: IsolatedServer) {
  return Promise.all(
    SEED_USERS.map(async (username) => (await (await api.send('GET', `${server.url}/users/${username}`)).json()).createdAt),
  );
}

Given('que guardo a data de criação dos usuários pré-cadastrados', async ({ api, world }) => {
  world.seedCreatedAt = await seedCreatedAt(api, required(world.server, 'o servidor isolado'));
});

Then('a data de criação dos usuários pré-cadastrados deve ser a mesma', async ({ api, world }) => {
  const current = await seedCreatedAt(api, required(world.server, 'o servidor isolado'));
  expect(current).toEqual(required(world.seedCreatedAt, 'as datas guardadas'));
});

Then('cada usuário pré-cadastrado deve aparecer uma única vez no banco', async ({ world }) => {
  const { users } = JSON.parse(readFileSync(required(world.server, 'o servidor isolado').dbPath, 'utf8'));
  for (const username of SEED_USERS) {
    expect(users.filter((user: { username: string }) => user.username === username), username).toHaveLength(1);
  }
});

Then('o arquivo do banco não deve conter a senha enviada', async ({ world }) => {
  const database = readFileSync(required(world.server, 'o servidor isolado').dbPath, 'utf8');
  expect(database).not.toContain(required(world.generatedPassword, 'a senha gerada'));
});
