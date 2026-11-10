const SESSION_KEY = 'marketplace.user';

const view = document.getElementById('view');
const messageBox = document.getElementById('message');
const cartCount = document.getElementById('cart-count');
const session = document.getElementById('session');
const confirmDialog = document.getElementById('confirm-dialog');
const confirmText = document.getElementById('confirm-text');

let renderToken = 0;

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => `&#${character.charCodeAt(0)};`);
}

function formatMoney(cents) {
  return (cents / 100).toLocaleString('en-US', { style: 'currency', currency: 'USD' });
}

function currentUser() {
  try {
    return localStorage.getItem(SESSION_KEY);
  } catch {
    return null;
  }
}

function setCurrentUser(username) {
  if (username) localStorage.setItem(SESSION_KEY, username);
  else localStorage.removeItem(SESSION_KEY);
}

async function api(method, url, body) {
  const response = await fetch(`/api${url}`, {
    method,
    headers: body ? { 'Content-Type': 'application/json' } : undefined,
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await response.json();
  if (!response.ok) {
    throw Object.assign(new Error(data.message), { code: data.code, status: response.status });
  }
  return data;
}

const cartUrl = (path = '') => `/users/${encodeURIComponent(currentUser())}/cart${path}`;

function showMessage(text, type = 'success') {
  messageBox.textContent = text;
  messageBox.className = `message ${type}`;
  messageBox.setAttribute('role', type === 'error' ? 'alert' : 'status');
  messageBox.hidden = false;
}

function clearMessage() {
  messageBox.hidden = true;
  messageBox.textContent = '';
}

function updateCartCount(cart) {
  cartCount.textContent = cart ? cart.totalItems : 0;
}

async function refreshCartCount() {
  if (!currentUser()) {
    updateCartCount(null);
    return;
  }
  try {
    updateCartCount(await api('GET', cartUrl()));
  } catch {
    updateCartCount(null);
  }
}

function renderSession() {
  const username = currentUser();
  session.innerHTML = username
    ? `<span id="logged-user">${escapeHtml(username)}</span>
       <button type="button" class="link-button" id="logout-button">Sign out</button>`
    : '<a href="/login" id="login-link" data-link>Sign in</a>';
}

function navigate(url) {
  history.pushState({}, '', url);
  clearMessage();
  render();
}

function askConfirmation(text) {
  confirmText.textContent = text;
  confirmDialog.returnValue = '';
  confirmDialog.showModal();
  return new Promise((resolve) => {
    confirmDialog.addEventListener('close', () => resolve(confirmDialog.returnValue === 'yes'), { once: true });
  });
}

function pageHeader(title, subtitle) {
  return `
    <h1 id="page-title">${escapeHtml(title)}</h1>
    ${subtitle ? `<p class="subtitle" id="page-subtitle">${escapeHtml(subtitle)}</p>` : ''}`;
}

function notFound(title) {
  view.innerHTML = `${pageHeader(title)}<a href="/" id="back-to-companies" data-link>Back to companies</a>`;
}

async function renderHome(token) {
  const companies = await api('GET', '/companies');
  if (token !== renderToken) return;
  view.innerHTML = `
    ${pageHeader('Choose a company', 'Browse the products, even without signing in.')}
    <div class="grid" id="company-list">
      ${companies
        .map((company) => {
          const id = `company-${escapeHtml(company.id)}`;
          return `
            <a class="card" href="/companies/${escapeHtml(company.id)}" id="${id}" data-link>
              <h2 id="${id}-name">${escapeHtml(company.name)}</h2>
              <p class="muted" id="${id}-description">${escapeHtml(company.description)}</p>
            </a>`;
        })
        .join('')}
    </div>`;
}

function productCard(product) {
  const [first] = product.options;
  const id = `product-${escapeHtml(product.id)}`;
  const selector =
    product.options.length > 1
      ? `<label>Size
          <select id="${id}-size" data-option-select>
            ${product.options
              .map(
                (option) =>
                  `<option value="${escapeHtml(option.id)}" data-price="${option.priceCents}">${escapeHtml(option.label)}</option>`,
              )
              .join('')}
          </select>
        </label>`
      : '';
  return `
    <article class="card" id="${id}" data-product-id="${escapeHtml(product.id)}" data-default-option="${escapeHtml(first.id)}">
      <h2 id="${id}-name">${escapeHtml(product.name)}</h2>
      <p class="price" id="${id}-price" data-price-label>${formatMoney(first.priceCents)}</p>
      ${selector}
      <button type="button" class="button" id="${id}-add" data-add>Add to cart</button>
    </article>`;
}

async function renderCompany(token, companyId) {
  let company;
  try {
    company = await api('GET', `/companies/${encodeURIComponent(companyId)}`);
  } catch (error) {
    if (token !== renderToken) return;
    if (error.status !== 404) throw error;
    notFound('Company not found');
    return;
  }
  if (token !== renderToken) return;

  view.innerHTML = `
    ${pageHeader(company.name, company.description)}
    <div class="grid" id="product-list" data-company-id="${escapeHtml(company.id)}">
      ${company.products.map(productCard).join('')}
    </div>`;
}

async function addToCart(card) {
  const companyId = card.closest('[data-company-id]').dataset.companyId;
  if (!currentUser()) {
    const next = encodeURIComponent(location.pathname);
    navigate(`/login?next=${next}`);
    showMessage('Sign in to add products to the cart.', 'error');
    return;
  }

  const select = card.querySelector('[data-option-select]');
  const item = {
    companyId,
    productId: card.dataset.productId,
    optionId: select ? select.value : card.dataset.defaultOption,
    quantity: 1,
  };

  try {
    let cart;
    try {
      cart = await api('POST', cartUrl('/items'), item);
    } catch (error) {
      if (error.code !== 'CART_COMPANY_CONFLICT') throw error;
      const confirmed = await askConfirmation(
        'Your cart has items from another company. If you continue, the cart will be cleared. Do you want to continue?',
      );
      if (!confirmed) return;
      cart = await api('POST', cartUrl('/items'), { ...item, replaceCart: true });
    }
    updateCartCount(cart);
    showMessage('Product added to the cart.');
  } catch (error) {
    showMessage(error.message, 'error');
  }
}

function renderLogin() {
  if (currentUser()) {
    navigate('/');
    return;
  }
  view.innerHTML = `
    ${pageHeader('Sign in', 'Use your account to build your cart.')}
    <form class="form" id="login-form">
      <label>Username <input id="login-username" name="username" autocomplete="username" required /></label>
      <label>Password <input id="login-password" name="password" type="password" autocomplete="current-password" required /></label>
      <button type="submit" class="button" id="login-submit">Sign in</button>
    </form>`;
}

function cartItemRow(item) {
  const id = `cart-item-${escapeHtml(item.productId)}-${escapeHtml(item.optionId)}`;
  return `
    <article class="card cart-item" id="${id}" data-item-id="${escapeHtml(item.id)}">
      <div>
        <h2 id="${id}-name">${escapeHtml(item.productName)}</h2>
        <p class="muted" id="${id}-details">${escapeHtml(item.companyName)} · ${escapeHtml(item.optionLabel)}</p>
        <p>Unit price: <span id="${id}-unit-price">${formatMoney(item.unitPriceCents)}</span></p>
        <p>Subtotal: <strong id="${id}-subtotal">${formatMoney(item.subtotalCents)}</strong></p>
      </div>
      <div class="item-controls">
        <label>Quantity <input type="number" min="1" max="99" step="1" value="${item.quantity}" id="${id}-quantity" data-quantity /></label>
        <button type="button" class="button secondary" id="${id}-update" data-update>Update</button>
        <button type="button" class="button secondary" id="${id}-delete" data-delete>Remove</button>
      </div>
    </article>`;
}

function drawCart(cart, { ready = false } = {}) {
  updateCartCount(cart);
  if (cart.items.length === 0) {
    view.innerHTML = `
      ${pageHeader('Cart')}
      <p class="subtitle" id="cart-empty-message">Your cart is empty.</p>
      <a class="button" href="/" id="cart-view-companies" data-link>View companies</a>`;
    return;
  }
  view.innerHTML = `
    ${pageHeader('Cart', 'Review your items before placing the order.')}
    <div class="cart-list" id="cart-list">${cart.items.map(cartItemRow).join('')}</div>
    <div class="summary">
      <p class="price">Total: <span id="cart-total">${formatMoney(cart.totalCents)}</span></p>
      <div class="actions">
        <button type="button" class="button secondary" id="checkout-button">Checkout</button>
        ${ready ? '<button type="button" class="button" id="pay-button">Pay</button>' : ''}
      </div>
    </div>`;
}

async function renderCart(token) {
  if (!currentUser()) {
    view.innerHTML = `
      ${pageHeader('Cart')}
      <p class="subtitle" id="cart-login-message">Sign in to view your cart.</p>
      <a class="button" href="/login?next=%2Fcart" id="cart-login-button" data-link>Sign in</a>`;
    return;
  }
  const cart = await api('GET', cartUrl());
  if (token === renderToken) drawCart(cart);
}

async function render() {
  const token = ++renderToken;
  renderSession();
  refreshCartCount();
  const { pathname } = location;
  const companyMatch = pathname.match(/^\/companies\/([^/]+)$/);

  try {
    if (pathname === '/') await renderHome(token);
    else if (pathname === '/login') renderLogin();
    else if (pathname === '/cart') await renderCart(token);
    else if (companyMatch) await renderCompany(token, decodeURIComponent(companyMatch[1]));
    else notFound('Page not found');
  } catch (error) {
    if (token === renderToken) showMessage(error.message || 'Failed to load the page.', 'error');
  }
}

async function handleCartAction(target) {
  const row = target.closest('[data-item-id]');
  clearMessage();
  try {
    if (target.matches('[data-update]')) {
      const quantity = Number(row.querySelector('[data-quantity]').value);
      drawCart(await api('PATCH', cartUrl(`/items/${row.dataset.itemId}`), { quantity }));
    } else if (target.matches('[data-delete]')) {
      drawCart(await api('DELETE', cartUrl(`/items/${row.dataset.itemId}`)));
    } else if (target.id === 'checkout-button') {
      await api('POST', cartUrl('/checkout'));
      drawCart(await api('GET', cartUrl()), { ready: true });
      showMessage('Order confirmed');
    } else if (target.id === 'pay-button') {
      const result = await api('POST', cartUrl('/pay'));
      drawCart(await api('GET', cartUrl()));
      showMessage(result.message);
    }
  } catch (error) {
    document.getElementById('pay-button')?.remove();
    showMessage(error.message, 'error');
  }
}

document.addEventListener('click', (event) => {
  const link = event.target.closest('a[data-link]');
  if (link) {
    event.preventDefault();
    navigate(link.getAttribute('href'));
    return;
  }

  const addButton = event.target.closest('[data-add]');
  if (addButton) {
    clearMessage();
    addToCart(addButton.closest('[data-product-id]'));
    return;
  }

  if (event.target.id === 'logout-button') {
    setCurrentUser(null);
    navigate('/');
    return;
  }

  if (event.target.matches('[data-update], [data-delete], #checkout-button, #pay-button')) {
    handleCartAction(event.target);
  }
});

document.addEventListener('change', (event) => {
  if (!event.target.matches('[data-option-select]')) return;
  const price = Number(event.target.selectedOptions[0].dataset.price);
  event.target.closest('[data-product-id]').querySelector('[data-price-label]').textContent = formatMoney(price);
});

document.addEventListener('submit', async (event) => {
  if (event.target.id !== 'login-form') return;
  event.preventDefault();
  clearMessage();
  const form = new FormData(event.target);
  try {
    const user = await api('POST', '/login', {
      username: form.get('username'),
      password: form.get('password'),
    });
    setCurrentUser(user.username);
    const next = new URLSearchParams(location.search).get('next');
    navigate(next && /^\/(?!\/)/.test(next) ? next : '/');
  } catch (error) {
    showMessage(error.message, 'error');
  }
});

document.getElementById('confirm-yes').addEventListener('click', () => confirmDialog.close('yes'));
document.getElementById('confirm-no').addEventListener('click', () => confirmDialog.close('no'));
window.addEventListener('popstate', () => {
  clearMessage();
  render();
});

render();
