const crypto = require('node:crypto');
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');
const catalog = require('./catalog');
const store = require('./store');

const HOST = process.env.HOST || '127.0.0.1';
const PORT = Number(process.env.PORT) || 3000;
const PUBLIC_DIR = path.join(__dirname, '..', 'public');
const MAX_BODY_BYTES = 100 * 1024;
const MAX_QUANTITY = 99;
const MIXED_MESSAGE = 'Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido.';

const STATIC_FILES = {
  '/app.js': ['app.js', 'text/javascript; charset=utf-8'],
  '/styles.css': ['styles.css', 'text/css; charset=utf-8'],
};

class ApiError extends Error {
  constructor(status, code, message) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

const validationError = (message) => new ApiError(400, 'VALIDATION_ERROR', message);

function publicUser(user) {
  return { username: user.username, createdAt: user.createdAt };
}

function requireUser(username) {
  const user = store.findUser(username);
  if (!user) throw new ApiError(404, 'USER_NOT_FOUND', 'Usuário não encontrado.');
  return user;
}

function requireItem(user, itemId) {
  const item = user.cart.find((candidate) => candidate.id === itemId);
  if (!item) throw new ApiError(404, 'ITEM_NOT_FOUND', 'Item não encontrado no carrinho.');
  return item;
}

function requireQuantity(quantity) {
  if (!Number.isInteger(quantity) || quantity < 1 || quantity > MAX_QUANTITY) {
    throw validationError(`A quantidade deve ser um número inteiro de 1 a ${MAX_QUANTITY}.`);
  }
}

function cartView(user) {
  const items = user.cart.map((item) => {
    const { company, product, option } = catalog.resolveItem(item.companyId, item.productId, item.optionId);
    return {
      id: item.id,
      companyId: company.id,
      companyName: company.name,
      productId: product.id,
      productName: product.name,
      optionId: option.id,
      optionLabel: option.label,
      unitPriceCents: option.priceCents,
      quantity: item.quantity,
      subtotalCents: option.priceCents * item.quantity,
    };
  });
  const companyIds = [...new Set(items.map((item) => item.companyId))];
  return {
    username: user.username,
    items,
    companyIds,
    hasMixedCompanies: companyIds.length > 1,
    totalItems: items.reduce((sum, item) => sum + item.quantity, 0),
    totalCents: items.reduce((sum, item) => sum + item.subtotalCents, 0),
  };
}

function requirePayableCart(user) {
  const cart = cartView(user);
  if (cart.items.length === 0) throw new ApiError(422, 'CART_EMPTY', 'O carrinho está vazio.');
  if (cart.hasMixedCompanies) throw new ApiError(422, 'CART_MIXED_COMPANIES', MIXED_MESSAGE);
  return cart;
}

function createUser(_params, body) {
  const { username, password } = body;
  if (typeof username !== 'string' || !/^[A-Za-z0-9_]{3,30}$/.test(username)) {
    throw validationError('O usuário deve ter de 3 a 30 caracteres: letras, números ou _.');
  }
  if (typeof password !== 'string' || password.length < 8) {
    throw validationError('A senha deve ter no mínimo 8 caracteres.');
  }
  if (store.findUser(username)) {
    throw new ApiError(409, 'USER_ALREADY_EXISTS', 'Este usuário já existe.');
  }
  return { status: 201, body: publicUser(store.createUser(username, password)) };
}

function getUser({ username }) {
  return { status: 200, body: publicUser(requireUser(username)) };
}

function login(_params, body) {
  const { username, password } = body;
  if (typeof username !== 'string' || typeof password !== 'string') {
    throw validationError('Informe usuário e senha.');
  }
  const user = store.findUser(username);
  if (!user || !store.verifyPassword(user, password)) {
    throw new ApiError(401, 'INVALID_CREDENTIALS', 'Usuário ou senha inválidos.');
  }
  return { status: 200, body: publicUser(user) };
}

function listCompanies() {
  // DEFEITO INTENCIONAL (BUG-04): o campo interno `commissionPercent` não faz parte do contrato
  // e não deveria ser retornado. O correto é `body: catalog.companies`.
  // Ver docs/HISTORIA_DO_PRODUTO.md, seção 10.
  return { status: 200, body: catalog.companies.map((company) => ({ ...company, commissionPercent: 12 })) };
}

function getCompany({ companyId }) {
  const company = catalog.findCompany(companyId);
  if (!company) throw new ApiError(404, 'COMPANY_NOT_FOUND', 'Empresa não encontrada.');
  return { status: 200, body: company };
}

function getCart({ username }) {
  return { status: 200, body: cartView(requireUser(username)) };
}

function addCartItem({ username }, body) {
  const user = requireUser(username);
  const { companyId, productId, optionId, quantity = 1, replaceCart = false } = body;
  requireQuantity(quantity);
  if (!catalog.resolveItem(companyId, productId, optionId)) {
    throw validationError('Empresa, produto ou opção inválidos.');
  }

  const hasOtherCompany = user.cart.some((item) => item.companyId !== companyId);
  if (hasOtherCompany && replaceCart !== true) {
    throw new ApiError(
      409,
      'CART_COMPANY_CONFLICT',
      'O carrinho contém itens de outra empresa. Se continuar, o carrinho será limpo.',
    );
  }

  // DEFEITO INTENCIONAL (BUG-01): com replaceCart, o carrinho deveria ser limpo aqui,
  // com `user.cart = []`. Ver docs/HISTORIA_DO_PRODUTO.md, seção 10.

  const existing = user.cart.find(
    (item) => item.companyId === companyId && item.productId === productId && item.optionId === optionId,
  );
  if (existing && existing.quantity + quantity > MAX_QUANTITY) {
    throw new ApiError(422, 'QUANTITY_LIMIT_EXCEEDED', `A quantidade do item não pode passar de ${MAX_QUANTITY}.`);
  }

  if (existing) {
    existing.quantity += quantity;
  } else {
    user.cart.push({ id: crypto.randomUUID(), companyId, productId, optionId, quantity });
  }
  store.save();
  return { status: 201, body: cartView(user) };
}

function updateCartItem({ username, itemId }, body) {
  const user = requireUser(username);
  const item = requireItem(user, itemId);
  requireQuantity(body.quantity);

  // DEFEITO INTENCIONAL (BUG-02): o correto é `item.quantity = body.quantity`.
  // Ver docs/HISTORIA_DO_PRODUTO.md, seção 10.
  item.quantity = body.quantity * 2;

  store.save();
  return { status: 200, body: cartView(user) };
}

function deleteCartItem({ username, itemId }) {
  const user = requireUser(username);
  const item = requireItem(user, itemId);
  user.cart.splice(user.cart.indexOf(item), 1);
  store.save();
  return { status: 200, body: cartView(user) };
}

function checkout({ username }) {
  const cart = cartView(requireUser(username));
  if (cart.items.length === 0) throw new ApiError(422, 'CART_EMPTY', 'O carrinho está vazio.');

  // DEFEITO INTENCIONAL (BUG-03): o carrinho com empresas diferentes deveria ser recusado aqui,
  // com `requirePayableCart`. Ver docs/HISTORIA_DO_PRODUTO.md, seção 10.

  return { status: 200, body: { status: 'READY_FOR_PAYMENT', totalCents: cart.totalCents } };
}

function pay({ username }) {
  const user = requireUser(username);
  const cart = requirePayableCart(user);
  user.cart = [];
  store.save();
  return {
    status: 200,
    body: { status: 'PAID', totalCents: cart.totalCents, message: 'Pagamento Fake efetuado' },
  };
}

const routes = [
  ['POST', /^\/api\/users$/, [], createUser],
  ['GET', /^\/api\/users\/([^/]+)$/, ['username'], getUser],
  ['POST', /^\/api\/login$/, [], login],
  ['GET', /^\/api\/companies$/, [], listCompanies],
  ['GET', /^\/api\/companies\/([^/]+)$/, ['companyId'], getCompany],
  ['GET', /^\/api\/users\/([^/]+)\/cart$/, ['username'], getCart],
  ['POST', /^\/api\/users\/([^/]+)\/cart\/items$/, ['username'], addCartItem],
  ['PATCH', /^\/api\/users\/([^/]+)\/cart\/items\/([^/]+)$/, ['username', 'itemId'], updateCartItem],
  ['DELETE', /^\/api\/users\/([^/]+)\/cart\/items\/([^/]+)$/, ['username', 'itemId'], deleteCartItem],
  ['POST', /^\/api\/users\/([^/]+)\/cart\/checkout$/, ['username'], checkout],
  ['POST', /^\/api\/users\/([^/]+)\/cart\/pay$/, ['username'], pay],
];

function sendJson(response, status, body) {
  response.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  response.end(JSON.stringify(body));
}

async function readJson(request) {
  const chunks = [];
  let size = 0;
  for await (const chunk of request) {
    size += chunk.length;
    if (size > MAX_BODY_BYTES) throw validationError('O corpo da requisição é muito grande.');
    chunks.push(chunk);
  }
  if (size === 0) return {};
  let body;
  try {
    body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
  } catch {
    throw validationError('O corpo da requisição deve ser um JSON válido.');
  }
  if (body === null || typeof body !== 'object' || Array.isArray(body)) {
    throw validationError('O corpo da requisição deve ser um objeto JSON.');
  }
  return body;
}

async function handleApi(request, response, pathname) {
  try {
    const matching = routes.filter(([, pattern]) => pattern.test(pathname));
    if (matching.length === 0) throw new ApiError(404, 'NOT_FOUND', 'Rota não encontrada.');

    const route = matching.find(([method]) => method === request.method);
    if (!route) throw new ApiError(405, 'METHOD_NOT_ALLOWED', 'Método não permitido.');

    const [, pattern, names, handler] = route;
    const values = pattern.exec(pathname).slice(1).map(decodeURIComponent);
    const params = Object.fromEntries(names.map((name, index) => [name, values[index]]));
    const result = handler(params, await readJson(request));
    sendJson(response, result.status, result.body);
  } catch (error) {
    if (error instanceof ApiError) {
      sendJson(response, error.status, { code: error.code, message: error.message });
    } else if (error instanceof URIError) {
      sendJson(response, 400, { code: 'VALIDATION_ERROR', message: 'URL inválida.' });
    } else {
      console.error(error);
      sendJson(response, 500, { code: 'INTERNAL_ERROR', message: 'Erro interno.' });
    }
  }
}

function handleStatic(response, pathname) {
  const [file, contentType] = STATIC_FILES[pathname] || ['index.html', 'text/html; charset=utf-8'];
  response.writeHead(200, { 'Content-Type': contentType, 'Cache-Control': 'no-cache' });
  fs.createReadStream(path.join(PUBLIC_DIR, file)).pipe(response);
}

store.seedUsers();

http
  .createServer((request, response) => {
    const { pathname } = new URL(request.url, 'http://localhost');
    if (pathname === '/api' || pathname.startsWith('/api/')) {
      handleApi(request, response, pathname);
    } else {
      handleStatic(response, pathname);
    }
  })
  .listen(PORT, HOST, () => {
    console.log(`Marketplace de Comida em http://${HOST}:${PORT}`);
  });
