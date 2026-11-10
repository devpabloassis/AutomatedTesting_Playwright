import { Locator, Page } from '@playwright/test';
import { ObjectMap } from '../object-map';

const map = ObjectMap.cart;

export class CartPage {
  readonly total: Locator;
  readonly checkout: Locator;
  readonly pay: Locator;
  readonly emptyMessage: Locator;
  readonly viewCompanies: Locator;
  readonly loginMessage: Locator;
  readonly loginButton: Locator;

  constructor(private readonly page: Page) {
    this.total = page.locator(map.total);
    this.checkout = page.locator(map.checkoutButton);
    this.pay = page.locator(map.payButton);
    this.emptyMessage = page.locator(map.emptyMessage);
    this.viewCompanies = page.locator(map.viewCompaniesLink);
    this.loginMessage = page.locator(map.loginMessage);
    this.loginButton = page.locator(map.loginButton);
  }

  async open() {
    await this.page.goto('/cart');
  }

  row(productId: string, optionId: string) {
    return this.page.locator(map.item(productId, optionId));
  }

  quantity(productId: string, optionId: string) {
    return this.page.locator(map.itemQuantity(productId, optionId));
  }

  subtotal(productId: string, optionId: string) {
    return this.page.locator(map.itemSubtotal(productId, optionId));
  }

  async updateQuantity(productId: string, optionId: string, value: string) {
    await this.quantity(productId, optionId).fill(value);
    await this.page.locator(map.itemUpdateButton(productId, optionId)).click();
  }

  async remove(productId: string, optionId: string) {
    await this.page.locator(map.itemDeleteButton(productId, optionId)).click();
  }
}
