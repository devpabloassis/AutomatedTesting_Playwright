import { Locator, Page } from '@playwright/test';
import { ObjectMap } from '../object-map';

const map = ObjectMap.header;

export class Header {
  readonly brand: Locator;
  readonly cartLink: Locator;
  readonly cartCount: Locator;
  readonly loggedUser: Locator;
  readonly logout: Locator;
  readonly loginLink: Locator;
  readonly message: Locator;

  constructor(page: Page) {
    this.brand = page.locator(map.brand);
    this.cartLink = page.locator(map.cartLink);
    this.cartCount = page.locator(map.cartCount);
    this.loggedUser = page.locator(map.loggedUser);
    this.logout = page.locator(map.logoutButton);
    this.loginLink = page.locator(map.loginLink);
    this.message = page.locator(ObjectMap.common.message);
  }
}
