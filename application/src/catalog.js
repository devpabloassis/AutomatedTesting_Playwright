const sized = (id, name, small, medium, large) => ({
  id,
  name,
  options: [
    { id: 'P', label: 'Pequeno', priceCents: small },
    { id: 'M', label: 'Médio', priceCents: medium },
    { id: 'G', label: 'Grande', priceCents: large },
  ],
});

const single = (id, name, price) => ({
  id,
  name,
  options: [{ id: 'U', label: 'Único', priceCents: price }],
});

const companies = [
  {
    id: 'pizzaria',
    name: 'Pizzaria Forno Nobre',
    description: 'Pizzas assadas no forno a lenha.',
    products: [
      sized('portuguesa', 'Portuguesa', 3890, 5290, 6690),
      sized('calabresa', 'Calabresa', 3490, 4890, 6290),
      sized('frango-catupiry', 'Frango com Catupiry', 3690, 5090, 6490),
      sized('marguerita', 'Marguerita', 3290, 4690, 6090),
    ],
  },
  {
    id: 'hamburgueria',
    name: 'Hamburgueria Chapa Quente',
    description: 'Hambúrgueres artesanais feitos na hora.',
    products: [
      single('vegano', 'Vegano', 3190),
      single('completo', 'Completo', 2990),
      single('eggburguer', 'Eggburguer', 2690),
      single('duplo', 'Duplo', 3690),
    ],
  },
  {
    id: 'japonesa',
    name: 'Japa Express',
    description: 'Yakissobas e hot rolls preparados no pedido.',
    products: [
      single('yakissoba-carne', 'Yakissoba de Carne', 3490),
      single('yakissoba-frango', 'Yakissoba de Frango', 3190),
      single('yakissoba-misto', 'Yakissoba Misto', 3790),
      single('hot-filadelfia', 'Hot Filadélfia', 2990),
    ],
  },
  {
    id: 'sucos',
    name: 'Sucos da Fruta',
    description: 'Sucos naturais de fruta fresca.',
    products: [
      sized('laranja', 'Laranja', 890, 1190, 1490),
      sized('abacaxi', 'Abacaxi', 990, 1290, 1590),
      sized('goiaba', 'Goiaba', 950, 1250, 1550),
      sized('acerola', 'Acerola', 900, 1200, 1500),
    ],
  },
];

function findCompany(companyId) {
  return companies.find((company) => company.id === companyId);
}

function resolveItem(companyId, productId, optionId) {
  const company = findCompany(companyId);
  const product = company?.products.find((candidate) => candidate.id === productId);
  const option = product?.options.find((candidate) => candidate.id === optionId);
  return option ? { company, product, option } : null;
}

module.exports = { companies, findCompany, resolveItem };
