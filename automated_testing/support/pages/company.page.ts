import { Locator, Page } from '@playwright/test';
import { ObjectMap } from '../object-map';

const map = ObjectMap.company;
const dialogMap = ObjectMap.confirmDialog;

export class CompanyPage {
  readonly title: Locator;
  readonly backToCompanies: Locator;
  readonly products: Locator;
  readonly dialog: Locator;
  readonly dialogText: Locator;
  readonly dialogYes: Locator;
  readonly dialogNo: Locator;

  constructor(private readonly page: Page) {
    this.title = page.locator(ObjectMap.common.pageTitle);
    this.backToCompanies = page.locator(ObjectMap.common.backToCompanies);
    this.products = page.locator(map.productCards);
    this.dialog = page.locator(dialogMap.dialog);
    this.dialogText = page.locator(dialogMap.text);
    this.dialogYes = page.locator(dialogMap.yesButton);
    this.dialogNo = page.locator(dialogMap.noButton);
  }

  async open(companyId: string) {
    await this.page.goto(`/companies/${companyId}`);
  }

  product(productId: string) {
    return this.page.locator(map.product(productId));
  }

  price(productId: string) {
    return this.page.locator(map.productPrice(productId));
  }

  size(productId: string) {
    return this.page.locator(map.productSize(productId));
  }

  async selectSize(productId: string, label: string) {
    await this.size(productId).selectOption({ label });
  }

  async add(productId: string) {
    await this.page.locator(map.productAddButton(productId)).click();
  }
}
