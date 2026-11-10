// Passos dos cenários Web.
import { expect } from '@playwright/test';
import { DataTable } from 'playwright-bdd';
import { MESSAGES, SESSION_KEY, uniqueName, VALID_PASSWORD } from '../support/data';
import { Given, Then, When } from '../support/fixtures';
import { required } from './common.steps';

// Referência de item no carrinho no formato "produto/opção", por exemplo "portuguesa/M".
const cartItem = (reference: string) => reference.split('/') as [string, string];

// Grava a sessão só na primeira carga da aba, para que "Sair" funcione normalmente depois.
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

// Sessão e preparação

Given('que estou logado com um usuário novo', async ({ api, world, page }) => {
  world.username = await api.newUser();
  await seedSession(page, world.username);
});

Given('que não estou logado', async () => {});

Given('que a sessão do navegador é de um usuário inexistente', async ({ page }) => {
  await seedSession(page, uniqueName());
});

Given('que a API responde com erro 500 em {string}', async ({ page }, pattern: string) => {
  await page.route(pattern, (route) =>
    route.fulfill({ status: 500, json: { code: 'INTERNAL_ERROR', message: MESSAGES.internalError } }),
  );
});

Given('que a tela tem largura de {int} pixels', async ({ page }, width: number) => {
  await page.setViewportSize({ width, height: 700 });
});

Given('que monitoro as requisições de login', async ({ page, world }) => {
  page.on('request', (request) => {
    if (request.url().includes('/api/login')) world.loginRequests.push(request.url());
  });
});

// Navegação

Given('que estou na página {string}', async ({ page }, path: string) => {
  await page.goto(path);
});

When('abro a página {string}', async ({ page }, path: string) => {
  await page.goto(path);
});

When('recarrego a página', async ({ page }) => {
  await page.reload();
});

When('volto pelo navegador', async ({ page }) => {
  await page.goBack();
});

When('clico na marca do cabeçalho', async ({ header }) => {
  await header.brand.click();
});

When('clico na empresa {string}', async ({ homePage }, companyId: string) => {
  await homePage.company(companyId).click();
});

When('navego pelo site até a empresa {string}', async ({ header, homePage, companyPage }, companyId: string) => {
  await header.brand.click();
  await homePage.company(companyId).click();
  await expect(companyPage.products.first()).toBeVisible();
});

Then('devo estar na página {string}', async ({ page }, path: string) => {
  await expect(page).toHaveURL(path);
});

Then('devo estar na página de login', async ({ page, loginPage }) => {
  await expect(page).toHaveURL(/\/login/);
  await expect(loginPage.username).toBeVisible();
});

Then('devo continuar no sistema', async ({ page, baseURL }) => {
  expect(new URL(page.url()).origin).toBe(new URL(baseURL!).origin);
});

Then('o título da página deve ser {string}', async ({ homePage }, title: string) => {
  await expect(homePage.title).toHaveText(title);
});

Then('devo ver o link para voltar às empresas', async ({ companyPage }) => {
  await expect(companyPage.backToCompanies).toBeVisible();
});

Then('devo ver {int} empresas', async ({ homePage }, count: number) => {
  await expect(homePage.companies).toHaveCount(count);
});

Then('devo ver {int} produtos', async ({ companyPage }, count: number) => {
  await expect(companyPage.products).toHaveCount(count);
});

Then(
  'cada empresa abaixo deve abrir a partir da página inicial com {int} produtos:',
  async ({ page, homePage, companyPage }, count: number, table: DataTable) => {
    for (const [companyId] of table.raw()) {
      await homePage.open();
      await homePage.company(companyId).click();
      await expect(page).toHaveURL(`/empresas/${companyId}`);
      await expect(companyPage.products).toHaveCount(count);
    }
  },
);

Then('a página não deve ter rolagem horizontal', async ({ page }) => {
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
});

// Mensagens e cabeçalho

Then('devo ver a mensagem {string}', async ({ header }, message: string) => {
  await expect(header.message).toHaveText(message);
});

Then('a mensagem {string} não deve aparecer', async ({ page }, message: string) => {
  await expect(page.getByText(message, { exact: true })).toHaveCount(0);
});

Then('o contador do carrinho deve mostrar {string}', async ({ header }, value: string) => {
  await expect(header.cartCount).toHaveText(value);
});

// Compara o contador com a soma das quantidades do carrinho guardado na API.
Then('o contador do carrinho deve corresponder ao carrinho do usuário', async ({ api, header, world }) => {
  const cart = await api.cart(required(world.username, 'o usuário'));
  await expect(header.cartCount).toHaveText(String(cart.totalItems));
});

Then('devo ver o link Entrar no cabeçalho', async ({ header }) => {
  await expect(header.loginLink).toBeVisible();
});

Then('devo ver o usuário criado no cabeçalho', async ({ header, world }) => {
  await expect(header.loggedUser).toHaveText(required(world.username, 'o usuário'));
});

Then('devo ver o botão Sair', async ({ header }) => {
  await expect(header.logout).toBeVisible();
});

Then('não devo estar logado', async ({ header }) => {
  await expect(header.loggedUser).toHaveCount(0);
});

When('clico em Sair', async ({ header }) => {
  await header.logout.click();
});

// Login

When('faço login com o usuário criado', async ({ loginPage, world }) => {
  await loginPage.login(required(world.username, 'o usuário'), VALID_PASSWORD);
});

When(
  'faço login com o usuário {string} e a senha {string}',
  async ({ loginPage }, username: string, password: string) => {
    await loginPage.login(username, password);
  },
);

When('faço login com um usuário inexistente e a senha {string}', async ({ loginPage }, password: string) => {
  await loginPage.login(uniqueName(), password);
});

When('clico em Entrar sem preencher os campos', async ({ loginPage }) => {
  await loginPage.submit.click();
});

Then('o campo usuário deve estar em foco', async ({ loginPage }) => {
  await expect(loginPage.username).toBeFocused();
});

Then('nenhuma requisição de login deve ter sido enviada', async ({ world }) => {
  expect(world.loginRequests).toEqual([]);
});

Then(
  'cada usuário abaixo deve conseguir entrar e sair com a senha {string}:',
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

// Produtos

When(
  'seleciono o tamanho {string} do produto {string}',
  async ({ companyPage }, size: string, productId: string) => {
    await companyPage.selectSize(productId, size);
  },
);

When('adiciono o produto {string} ao carrinho', async ({ companyPage }, productId: string) => {
  await companyPage.add(productId);
});

Then(
  'o tamanho selecionado do produto {string} deve ser {string}',
  async ({ companyPage }, productId: string, optionId: string) => {
    await expect(companyPage.size(productId)).toHaveValue(optionId);
  },
);

Then('o preço do produto {string} deve ser {string}', async ({ companyPage }, productId: string, price: string) => {
  await expect(companyPage.price(productId)).toHaveText(price);
});

Then('o produto {string} não deve ter seletor de tamanho', async ({ companyPage }, productId: string) => {
  await expect(companyPage.product(productId)).toBeVisible();
  await expect(companyPage.size(productId)).toHaveCount(0);
});

// Aviso de troca de empresa

Then('o aviso de troca de empresa deve exibir o texto {string}', async ({ companyPage }, text: string) => {
  await expect(companyPage.dialogText).toContainText(text);
});

Then('o aviso de troca de empresa deve ter as opções Sim e Não', async ({ companyPage }) => {
  await expect(companyPage.dialogYes).toBeVisible();
  await expect(companyPage.dialogNo).toBeVisible();
});

Then('o aviso de troca de empresa deve estar visível', async ({ companyPage }) => {
  await expect(companyPage.dialog).toBeVisible();
});

Then('o aviso de troca de empresa não deve estar visível', async ({ companyPage }) => {
  await expect(companyPage.dialog).toBeHidden();
});

When('confirmo a troca de empresa com {string}', async ({ companyPage }, answer: string) => {
  await (answer === 'Sim' ? companyPage.dialogYes : companyPage.dialogNo).click();
});

When('fecho o aviso com a tecla Esc', async ({ companyPage, page }) => {
  await expect(companyPage.dialog).toBeVisible();
  await page.keyboard.press('Escape');
});

// Carrinho

When('altero a quantidade do item {string} para {string}', async ({ cartPage }, reference: string, value: string) => {
  await cartPage.updateQuantity(...cartItem(reference), value);
});

When('excluo o item {string}', async ({ cartPage }, reference: string) => {
  await cartPage.remove(...cartItem(reference));
});

When('finalizo o pedido', async ({ cartPage }) => {
  await cartPage.finalize.click();
});

When('clico em Pagar', async ({ cartPage }) => {
  await cartPage.pay.click();
});

When('clico no botão Entrar do carrinho', async ({ cartPage }) => {
  await cartPage.loginButton.click();
});

Then('a linha do item {string} deve exibir:', async ({ cartPage }, reference: string, table: DataTable) => {
  for (const [text] of table.raw()) await expect(cartPage.row(...cartItem(reference))).toContainText(text);
});

Then('devo ver o item {string} no carrinho', async ({ cartPage }, reference: string) => {
  await expect(cartPage.row(...cartItem(reference))).toBeVisible();
});

Then('o item {string} não deve estar no carrinho', async ({ cartPage }, reference: string) => {
  await expect(cartPage.row(...cartItem(reference))).toHaveCount(0);
});

Then(
  'a quantidade do item {string} na tela deve ser {string}',
  async ({ cartPage }, reference: string, value: string) => {
    await expect(cartPage.quantity(...cartItem(reference))).toHaveValue(value);
  },
);

Then('o subtotal do item {string} deve ser {string}', async ({ cartPage }, reference: string, value: string) => {
  await expect(cartPage.subtotal(...cartItem(reference))).toHaveText(value);
});

Then('o total do carrinho deve ser {string}', async ({ cartPage }, value: string) => {
  await expect(cartPage.total).toHaveText(value);
});

Then('o total do carrinho não deve ser mais {string}', async ({ cartPage }, value: string) => {
  await expect(cartPage.total).not.toHaveText(value);
});

Then('devo ver o aviso de carrinho vazio', async ({ cartPage }) => {
  await expect(cartPage.emptyMessage).toHaveText(MESSAGES.emptyCart);
});

Then('devo ver o link Ver empresas', async ({ cartPage }) => {
  await expect(cartPage.viewCompanies).toBeVisible();
});

Then('devo ver o aviso de login do carrinho {string}', async ({ cartPage }, message: string) => {
  await expect(cartPage.loginMessage).toHaveText(message);
});

Then('devo ver o botão Entrar do carrinho', async ({ cartPage }) => {
  await expect(cartPage.loginButton).toBeVisible();
});

Then('o botão Pagar deve estar visível', async ({ cartPage }) => {
  await expect(cartPage.pay).toBeVisible();
});

Then('o botão Pagar não deve estar visível', async ({ cartPage }) => {
  await expect(cartPage.pay).toHaveCount(0);
});

Then('o botão Finalizar pedido deve estar visível', async ({ cartPage }) => {
  await expect(cartPage.finalize).toBeVisible();
});

Then('o botão Finalizar pedido não deve estar visível', async ({ cartPage }) => {
  await expect(cartPage.finalize).toHaveCount(0);
});
