// Object map: the selector of every UI element used by the tests.
// Every element has a unique id in the HTML. For repeated elements, the id includes the item.

export const ObjectMap = {
  common: {
    pageTitle: '#page-title',
    pageSubtitle: '#page-subtitle',
    message: '#message',
    backToCompanies: '#back-to-companies',
  },

  header: {
    brand: '#header-brand',
    cartLink: '#header-cart-link',
    cartCount: '#cart-count',
    loggedUser: '#logged-user',
    logoutButton: '#logout-button',
    loginLink: '#login-link',
  },

  home: {
    companyList: '#company-list',
    companyCards: '#company-list > a',
    company: (companyId: string) => `#company-${companyId}`,
    companyName: (companyId: string) => `#company-${companyId}-name`,
    companyDescription: (companyId: string) => `#company-${companyId}-description`,
  },

  company: {
    productList: '#product-list',
    productCards: '#product-list > article',
    product: (productId: string) => `#product-${productId}`,
    productName: (productId: string) => `#product-${productId}-name`,
    productPrice: (productId: string) => `#product-${productId}-price`,
    productSize: (productId: string) => `#product-${productId}-size`,
    productAddButton: (productId: string) => `#product-${productId}-add`,
  },

  confirmDialog: {
    dialog: '#confirm-dialog',
    title: '#confirm-title',
    text: '#confirm-text',
    yesButton: '#confirm-yes',
    noButton: '#confirm-no',
  },

  login: {
    form: '#login-form',
    username: '#login-username',
    password: '#login-password',
    submitButton: '#login-submit',
  },

  cart: {
    emptyMessage: '#cart-empty-message',
    viewCompaniesLink: '#cart-view-companies',
    loginMessage: '#cart-login-message',
    loginButton: '#cart-login-button',
    itemList: '#cart-list',
    item: (productId: string, optionId: string) => `#cart-item-${productId}-${optionId}`,
    itemName: (productId: string, optionId: string) => `#cart-item-${productId}-${optionId}-name`,
    itemDetails: (productId: string, optionId: string) => `#cart-item-${productId}-${optionId}-details`,
    itemUnitPrice: (productId: string, optionId: string) => `#cart-item-${productId}-${optionId}-unit-price`,
    itemQuantity: (productId: string, optionId: string) => `#cart-item-${productId}-${optionId}-quantity`,
    itemUpdateButton: (productId: string, optionId: string) => `#cart-item-${productId}-${optionId}-update`,
    itemDeleteButton: (productId: string, optionId: string) => `#cart-item-${productId}-${optionId}-delete`,
    itemSubtotal: (productId: string, optionId: string) => `#cart-item-${productId}-${optionId}-subtotal`,
    total: '#cart-total',
    checkoutButton: '#checkout-button',
    payButton: '#pay-button',
  },
} as const;
