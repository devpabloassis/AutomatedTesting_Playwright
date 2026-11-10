import { Locator, Page } from '@playwright/test';
import { ObjectMap } from '../object-map';

const map = ObjectMap.login;

export class LoginPage {
  readonly username: Locator;
  readonly password: Locator;
  readonly submit: Locator;

  constructor(private readonly page: Page) {
    this.username = page.locator(map.username);
    this.password = page.locator(map.password);
    this.submit = page.locator(map.submitButton);
  }

  async open(query = '') {
    await this.page.goto(`/login${query}`);
  }

  async login(username: string, password: string) {
    await this.username.fill(username);
    await this.password.fill(password);
    await this.submit.click();
  }
}
