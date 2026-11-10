import { randomUUID } from 'node:crypto';

export const SEED_USERS = ['user_manual', 'user_robot', 'user_hybrid', 'user_fail'];
export const SEED_PASSWORD = 'loveMetalSongs@';
export const VALID_PASSWORD = 'validPass1';
export const SESSION_KEY = 'marketplace.user';

export const PIZZA = { companyId: 'pizzeria', productId: 'supreme', optionId: 'M' };
export const PIZZA_2 = { companyId: 'pizzeria', productId: 'pepperoni', optionId: 'S' };
export const BURGER = { companyId: 'burgers', productId: 'double', optionId: 'R' };

export const COMPANY_IDS = ['pizzeria', 'burgers', 'japanese', 'juices'];

export const PRICES: Record<string, Record<string, number[]>> = {
  pizzeria: {
    supreme: [3890, 5290, 6690],
    pepperoni: [3490, 4890, 6290],
    'chicken-cheese': [3690, 5090, 6490],
    margherita: [3290, 4690, 6090],
  },
  burgers: { vegan: [3190], classic: [2990], 'egg-burger': [2690], double: [3690] },
  japanese: {
    'beef-yakisoba': [3490],
    'chicken-yakisoba': [3190],
    'mixed-yakisoba': [3790],
    'philly-hot-roll': [2990],
  },
  juices: {
    orange: [890, 1190, 1490],
    pineapple: [990, 1290, 1590],
    guava: [950, 1250, 1550],
    acerola: [900, 1200, 1500],
  },
};

export const MESSAGES = {
  invalidLogin: 'Invalid username or password.',
  added: 'Product added to the cart.',
  loginToAdd: 'Sign in to add products to the cart.',
  quantityLimit: 'Item quantity cannot exceed 99.',
  quantityRange: 'Quantity must be an integer from 1 to 99.',
  emptyCart: 'Your cart is empty.',
  cartIsEmpty: 'The cart is empty.',
  checkoutOk: 'Order confirmed',
  mixedCompanies: 'The cart has items from different companies. The order cannot be completed.',
  paid: 'Fake payment completed',
  internalError: 'Internal error.',
};

export const SQL_PAYLOADS: [string, string][] = [
  ['SQL-01', `' OR '1'='1`],
  ['SQL-02', `' OR 1=1--`],
  ['SQL-03', `admin'--`],
  ['SQL-04', `'; DROP TABLE users;--`],
  ['SQL-05', `" OR ""="`],
  ['SQL-06', `' UNION SELECT username, password FROM users--`],
  ['SQL-07', `1; SELECT pg_sleep(5)--`],
  ['SQL-08', `') OR ('1'='1`],
];

// Unique names allow the tests to run again against the same database, as in --ui mode.
export function uniqueName(): string {
  return `u${randomUUID().replaceAll('-', '').slice(0, 20)}`;
}
