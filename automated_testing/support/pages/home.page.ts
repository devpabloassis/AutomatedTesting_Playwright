import { Locator, Page } from '@playwright/test';
import { ObjectMap } from '../object-map';

const map = ObjectMap.home;

export class HomePage {
  readonly title: Locator;
  readonly companies: Locator;

  constructor(private readonly page: Page) {
    this.title = page.locator(ObjectMap.common.pageTitle);
    this.companies = page.locator(map.companyCards);
  }

  async open() {
    await this.page.goto('/');
  }

  company(companyId: string) {
    return this.page.locator(map.company(companyId));
  }
}
