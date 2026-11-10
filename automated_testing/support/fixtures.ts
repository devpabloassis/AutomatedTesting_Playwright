import { createBdd, test as base } from 'playwright-bdd';
import { Cart, MarketApi } from './api/market-api';
import { IsolatedServer } from './isolated-server';
import { CartPage } from './pages/cart.page';
import { CompanyPage } from './pages/company.page';
import { Header } from './pages/header.component';
import { HomePage } from './pages/home.page';
import { LoginPage } from './pages/login.page';

export interface ApiResponseData {
  status: number;
  headers: Record<string, string>;
  text: string;
  json: any;
}

// State shared between the steps of a single scenario.
export interface World {
  username?: string;
  otherUsername?: string;
  itemId?: string;
  otherItemId?: string;
  payload?: string;
  generatedName?: string;
  generatedPassword?: string;
  lastBody?: any;
  response?: ApiResponseData;
  server?: IsolatedServer;
  seedCreatedAt?: unknown[];
  cartSnapshot?: Cart;
  loginRequests: string[];
}

interface MarketFixtures {
  api: MarketApi;
  world: World;
  header: Header;
  homePage: HomePage;
  loginPage: LoginPage;
  companyPage: CompanyPage;
  cartPage: CartPage;
}

export const test = base.extend<MarketFixtures>({
  // Uses its own context so it does not depend on the page session.
  api: async ({ playwright, baseURL }, use) => {
    const http = await playwright.request.newContext({ baseURL });
    await use(new MarketApi(http));
    await http.dispose();
  },
  world: async ({}, use) => {
    const world: World = { loginRequests: [] };
    await use(world);
    await world.server?.stop();
  },
  header: async ({ page }, use) => use(new Header(page)),
  homePage: async ({ page }, use) => use(new HomePage(page)),
  loginPage: async ({ page }, use) => use(new LoginPage(page)),
  companyPage: async ({ page }, use) => use(new CompanyPage(page)),
  cartPage: async ({ page }, use) => use(new CartPage(page)),
});

export const { Given, When, Then } = createBdd(test);
