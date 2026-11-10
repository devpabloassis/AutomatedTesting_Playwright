import { APIRequestContext, APIResponse, expect } from '@playwright/test';
import { PIZZA, uniqueName, VALID_PASSWORD } from '../data';

export interface CartItem {
  id: string;
  companyId: string;
  productId: string;
  optionId: string;
  quantity: number;
  subtotalCents: number;
}

export interface Cart {
  username: string;
  items: CartItem[];
  companyIds: string[];
  hasMixedCompanies: boolean;
  totalItems: number;
  totalCents: number;
}

const JSON_HEADERS = { 'Content-Type': 'application/json' };
const encode = encodeURIComponent;

export class MarketApi {
  constructor(private readonly http: APIRequestContext) {}

  // Sends a request to a URL relative to the base URL (/api/...) or to an absolute URL.
  send(method: string, url: string, body?: string) {
    return this.http.fetch(url, {
      method,
      ...(body === undefined ? {} : { data: body, headers: JSON_HEADERS }),
    });
  }

  get(path: string) {
    return this.http.get(`/api${path}`);
  }

  delete(path: string) {
    return this.http.delete(`/api${path}`);
  }

  createUser(data?: unknown) {
    return this.http.post('/api/users', data === undefined ? {} : { data });
  }

  createUserRaw(body: string) {
    return this.http.post('/api/users', { data: body, headers: JSON_HEADERS });
  }

  getUser(username: string) {
    return this.get(`/users/${encode(username)}`);
  }

  login(data: unknown) {
    return this.http.post('/api/login', { data });
  }

  getCompanies() {
    return this.get('/companies');
  }

  getCompany(companyId: string) {
    return this.get(`/companies/${encode(companyId)}`);
  }

  getCart(username: string) {
    return this.get(this.cartPath(username));
  }

  addItem(username: string, data: unknown) {
    return this.http.post(`/api${this.cartPath(username)}/items`, { data });
  }

  addItemRaw(username: string, body: string) {
    return this.http.post(`/api${this.cartPath(username)}/items`, { data: body, headers: JSON_HEADERS });
  }

  updateItem(username: string, itemId: string, data: unknown) {
    return this.http.patch(`/api${this.cartPath(username)}/items/${encode(itemId)}`, { data });
  }

  updateItemRaw(username: string, itemId: string, body: string) {
    return this.http.patch(`/api${this.cartPath(username)}/items/${encode(itemId)}`, {
      data: body,
      headers: JSON_HEADERS,
    });
  }

  deleteItem(username: string, itemId: string) {
    return this.delete(`${this.cartPath(username)}/items/${encode(itemId)}`);
  }

  checkout(username: string) {
    return this.http.post(`/api${this.cartPath(username)}/checkout`);
  }

  pay(username: string) {
    return this.http.post(`/api${this.cartPath(username)}/pay`);
  }

  async newUser(): Promise<string> {
    const username = uniqueName();
    expect((await this.createUser({ username, password: VALID_PASSWORD })).status()).toBe(201);
    return username;
  }

  async cart(username: string): Promise<Cart> {
    const response = await this.getCart(username);
    expect(response.status()).toBe(200);
    return response.json();
  }

  async seedItem(username: string, data: unknown): Promise<Cart> {
    const response = await this.addItem(username, data);
    expect(response.status()).toBe(201);
    return response.json();
  }

  async newUserWithItem(): Promise<{ username: string; itemId: string }> {
    const username = await this.newUser();
    const cart = await this.seedItem(username, PIZZA);
    return { username, itemId: cart.items[0].id };
  }

  async emptyCart(username: string): Promise<void> {
    for (const item of (await this.cart(username)).items) {
      expect((await this.deleteItem(username, item.id)).status()).toBe(200);
    }
  }

  private cartPath(username: string) {
    return `/users/${encode(username)}/cart`;
  }
}

export async function expectError(response: APIResponse, status: number, code: string) {
  expect(response.status()).toBe(status);
  expect((await response.json()).code).toBe(code);
}

export async function expectStatus<T = any>(response: APIResponse, status: number): Promise<T> {
  expect(response.status()).toBe(status);
  return response.json();
}
