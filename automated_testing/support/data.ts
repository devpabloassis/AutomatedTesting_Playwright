import { randomUUID } from 'node:crypto';

export const SEED_USERS = ['user_manual', 'user_robot', 'user_hybrid', 'user_fail'];
export const SEED_PASSWORD = 'loveMetalSongs@';
export const VALID_PASSWORD = 'senhaValida1';
export const SESSION_KEY = 'marketplace.user';

export const PIZZA = { companyId: 'pizzaria', productId: 'portuguesa', optionId: 'M' };
export const PIZZA_2 = { companyId: 'pizzaria', productId: 'calabresa', optionId: 'P' };
export const BURGER = { companyId: 'hamburgueria', productId: 'duplo', optionId: 'U' };

export const COMPANY_IDS = ['pizzaria', 'hamburgueria', 'japonesa', 'sucos'];

export const PRICES: Record<string, Record<string, number[]>> = {
  pizzaria: {
    portuguesa: [3890, 5290, 6690],
    calabresa: [3490, 4890, 6290],
    'frango-catupiry': [3690, 5090, 6490],
    marguerita: [3290, 4690, 6090],
  },
  hamburgueria: { vegano: [3190], completo: [2990], eggburguer: [2690], duplo: [3690] },
  japonesa: {
    'yakissoba-carne': [3490],
    'yakissoba-frango': [3190],
    'yakissoba-misto': [3790],
    'hot-filadelfia': [2990],
  },
  sucos: {
    laranja: [890, 1190, 1490],
    abacaxi: [990, 1290, 1590],
    goiaba: [950, 1250, 1550],
    acerola: [900, 1200, 1500],
  },
};

export const MESSAGES = {
  invalidLogin: 'Usuário ou senha inválidos.',
  added: 'Produto adicionado ao carrinho.',
  loginToAdd: 'Entre na sua conta para adicionar produtos ao carrinho.',
  quantityLimit: 'A quantidade do item não pode passar de 99.',
  quantityRange: 'A quantidade deve ser um número inteiro de 1 a 99.',
  emptyCart: 'Seu carrinho está vazio.',
  cartIsEmpty: 'O carrinho está vazio.',
  checkoutOk: 'Pedido Concluído',
  mixedCompanies: 'Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido.',
  paid: 'Pagamento Fake efetuado',
  internalError: 'Erro interno.',
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

// Nomes únicos permitem repetir os testes no mesmo banco, como no modo --ui.
export function uniqueName(): string {
  return `u${randomUUID().replaceAll('-', '').slice(0, 20)}`;
}
