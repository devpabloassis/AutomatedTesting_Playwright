# Documentação da API — Marketplace de Comida

| Campo | Valor |
|---|---|
| URL base | `http://127.0.0.1:3000/api` (testes: `http://127.0.0.1:3100/api`) |
| Formato | JSON em requisições e respostas (`Content-Type: application/json; charset=utf-8`) |
| Autenticação | Não há token. O usuário é identificado pelo `:username` da rota |
| Valores monetários | Inteiros em centavos (`5290` = R$ 52,90) |
| Contratos | JSON Schemas em [`automated_testing/contracts/`](../automated_testing/contracts/) |
| Regras de negócio | [`HISTORIA_DO_PRODUTO.md`](./HISTORIA_DO_PRODUTO.md) |
| Cenários de teste | [`REPOSITORIO_TESTES_API.md`](./REPOSITORIO_TESTES_API.md) |

## Sumário

| # | Método | Rota | Finalidade | Sucesso | Contrato de sucesso |
|---|---|---|---|---|---|
| 1 | POST | [`/users`](#1-post-users--criar-usuário) | Criar usuário | 201 | `user` |
| 2 | GET | [`/users/:username`](#2-get-usersusername--consultar-usuário) | Consultar usuário | 200 | `user` |
| 3 | POST | [`/login`](#3-post-login--fazer-login) | Validar credenciais | 200 | `user` |
| 4 | GET | [`/companies`](#4-get-companies--listar-empresas) | Listar empresas e produtos | 200 | `companies` |
| 5 | GET | [`/companies/:companyId`](#5-get-companiescompanyid--consultar-empresa) | Consultar uma empresa | 200 | `company` |
| 6 | GET | [`/users/:username/cart`](#6-get-usersusernamecart--consultar-carrinho) | Consultar carrinho | 200 | `cart` |
| 7 | POST | [`/users/:username/cart/items`](#7-post-usersusernamecartitems--adicionar-item) | Adicionar item | 201 | `cart` |
| 8 | PATCH | [`/users/:username/cart/items/:itemId`](#8-patch-usersusernamecartitemsitemid--alterar-quantidade) | Alterar quantidade | 200 | `cart` |
| 9 | DELETE | [`/users/:username/cart/items/:itemId`](#9-delete-usersusernamecartitemsitemid--excluir-item) | Excluir item | 200 | `cart` |
| 10 | POST | [`/users/:username/cart/checkout`](#10-post-usersusernamecartcheckout--finalizar-pedido) | Finalizar pedido | 200 | `checkout` |
| 11 | POST | [`/users/:username/cart/pay`](#11-post-usersusernamecartpay--pagar) | Pagar (fake) | 200 | `payment` |

## Regras comuns

### Formato de erro

Toda resposta de erro segue o contrato `error`:

```json
{ "code": "USER_NOT_FOUND", "message": "Usuário não encontrado." }
```

| Código | Status | Quando ocorre |
|---|---|---|
| `VALIDATION_ERROR` | 400 | Campo fora do domínio, JSON inválido, corpo maior que 100 KB ou URL inválida |
| `INVALID_CREDENTIALS` | 401 | Usuário ou senha não conferem |
| `USER_NOT_FOUND` | 404 | O `:username` não existe |
| `COMPANY_NOT_FOUND` | 404 | O `:companyId` não existe |
| `ITEM_NOT_FOUND` | 404 | O `:itemId` não existe no carrinho do usuário |
| `NOT_FOUND` | 404 | Rota inexistente |
| `METHOD_NOT_ALLOWED` | 405 | A rota existe, mas não aceita o método |
| `USER_ALREADY_EXISTS` | 409 | Nome de usuário já cadastrado |
| `CART_COMPANY_CONFLICT` | 409 | O item é de outra empresa e a troca não foi confirmada |
| `QUANTITY_LIMIT_EXCEEDED` | 422 | A soma das quantidades do item passaria de 99 |
| `CART_EMPTY` | 422 | Finalizar ou pagar um carrinho vazio |
| `CART_MIXED_COMPANIES` | 422 | Carrinho com itens de empresas diferentes |
| `INTERNAL_ERROR` | 500 | Erro inesperado |

### Corpo da requisição

- Quando enviado, deve ser um **objeto** JSON. Lista, texto ou `null` retornam 400 `VALIDATION_ERROR`.
- Corpo vazio equivale a `{}`.
- O limite é de 100 KB.

### Tratamento de entrada

A API valida apenas o **domínio** dos campos (tipo, tamanho e caracteres permitidos). Não existe filtro específico para SQL injection: um payload é tratado como texto comum. Os dados são gravados em arquivo JSON, sem banco SQL.

### Contrato da resposta

Os contratos não aceitam campos a mais (`additionalProperties: false`). Um campo novo na resposta é uma quebra de contrato e precisa ser combinado com os consumidores antes de ser publicado.

---

## 1. `POST /users` — Criar usuário

Regras: RN-18, RN-19.

**Corpo**

| Campo | Tipo | Obrigatório | Domínio |
|---|---|---|---|
| `username` | string | Sim | 3 a 30 caracteres: `A-Z`, `a-z`, `0-9` e `_` |
| `password` | string | Sim | No mínimo 8 caracteres, qualquer caractere |

```json
{ "username": "novo_usuario", "password": "senhaSegura1" }
```

**Resposta 201** — contrato `user`

```json
{ "username": "novo_usuario", "createdAt": "2026-11-09T18:56:00.000Z" }
```

A senha é gravada com hash e nunca é retornada.

**Erros**

| Status | Código | Causa |
|---|---|---|
| 400 | `VALIDATION_ERROR` | `username` ou `password` fora do domínio |
| 409 | `USER_ALREADY_EXISTS` | `username` já cadastrado (diferencia maiúsculas) |

## 2. `GET /users/:username` — Consultar usuário

**Parâmetros:** `username`, comparado de forma exata.

**Resposta 200** — contrato `user`

```json
{ "username": "user_manual", "createdAt": "2026-11-09T12:00:00.000Z" }
```

**Erros:** 404 `USER_NOT_FOUND`.

## 3. `POST /login` — Fazer login

Regras: RN-02, RN-03.

**Corpo**

| Campo | Tipo | Obrigatório |
|---|---|---|
| `username` | string | Sim |
| `password` | string | Sim |

```json
{ "username": "user_manual", "password": "loveMetalSongs@" }
```

**Resposta 200** — contrato `user`, igual à consulta de usuário.

**Erros**

| Status | Código | Causa |
|---|---|---|
| 400 | `VALIDATION_ERROR` | `username` ou `password` ausente ou que não é texto |
| 401 | `INVALID_CREDENTIALS` | Usuário inexistente ou senha incorreta. A mensagem é a mesma nos dois casos |

## 4. `GET /companies` — Listar empresas

Regra: RN-01. Não exige login.

**Resposta 200** — contrato `companies`: lista de empresas, cada uma no formato do contrato `company`.

```json
[
  {
    "id": "pizzaria",
    "name": "Pizzaria Forno Nobre",
    "description": "Pizzas assadas no forno a lenha.",
    "products": [
      {
        "id": "portuguesa",
        "name": "Portuguesa",
        "options": [
          { "id": "P", "label": "Pequeno", "priceCents": 3890 },
          { "id": "M", "label": "Médio", "priceCents": 5290 },
          { "id": "G", "label": "Grande", "priceCents": 6690 }
        ]
      }
    ]
  }
]
```

Empresas: `pizzaria`, `hamburgueria`, `japonesa` e `sucos`, com 4 produtos cada.

> **Defeito intencional (BUG-04):** cada empresa da lista também traz o campo interno `commissionPercent`, que não faz parte do contrato. O cenário `CT-API-CON-008` falha por isso.

## 5. `GET /companies/:companyId` — Consultar empresa

**Parâmetros:** `companyId`, comparado de forma exata (`Pizzaria` não encontra `pizzaria`).

**Resposta 200** — contrato `company`: um único objeto, no mesmo formato de cada elemento da listagem.

**Erros:** 404 `COMPANY_NOT_FOUND`.

## 6. `GET /users/:username/cart` — Consultar carrinho

Regras: RN-04, RN-12.

**Resposta 200** — contrato `cart`

```json
{
  "username": "user_manual",
  "items": [
    {
      "id": "6f1c2a4e-0d6b-4c55-9a3e-2b7d1f0c9e11",
      "companyId": "pizzaria",
      "companyName": "Pizzaria Forno Nobre",
      "productId": "portuguesa",
      "productName": "Portuguesa",
      "optionId": "M",
      "optionLabel": "Médio",
      "unitPriceCents": 5290,
      "quantity": 2,
      "subtotalCents": 10580
    }
  ],
  "companyIds": ["pizzaria"],
  "hasMixedCompanies": false,
  "totalItems": 2,
  "totalCents": 10580
}
```

| Campo | Significado |
|---|---|
| `items[].id` | UUID do item. É o `:itemId` usado para alterar e excluir |
| `subtotalCents` | `unitPriceCents × quantity` |
| `companyIds` | Empresas presentes no carrinho, sem repetição |
| `hasMixedCompanies` | `true` quando há mais de uma empresa |
| `totalItems` | Soma das quantidades. É o número exibido no contador do cabeçalho |
| `totalCents` | Soma dos subtotais |

**Erros:** 404 `USER_NOT_FOUND`.

## 7. `POST /users/:username/cart/items` — Adicionar item

Regras: RN-05 a RN-10.

**Corpo**

| Campo | Tipo | Obrigatório | Domínio |
|---|---|---|---|
| `companyId` | string | Sim | Id exato de uma empresa |
| `productId` | string | Sim | Id exato de um produto dessa empresa |
| `optionId` | string | Sim | `P`, `M` ou `G` (produtos com tamanho) ou `U` (opção única) |
| `quantity` | integer | Não (padrão 1) | 1 a 99 |
| `replaceCart` | boolean | Não (padrão `false`) | Somente `true` confirma a troca de empresa e deve limpar o carrinho |

```json
{ "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": 1 }
```

- O mesmo produto e opção soma a quantidade ao item existente.
- Produto de outra empresa, sem `replaceCart: true`, retorna 409 e o carrinho não muda.

**Resposta 201** — contrato `cart`, com o carrinho atualizado.

**Erros**

| Status | Código | Causa |
|---|---|---|
| 400 | `VALIDATION_ERROR` | Empresa, produto ou opção inválidos, ou `quantity` fora de 1 a 99 |
| 404 | `USER_NOT_FOUND` | Usuário inexistente |
| 409 | `CART_COMPANY_CONFLICT` | Item de outra empresa sem confirmação |
| 422 | `QUANTITY_LIMIT_EXCEEDED` | A soma passaria de 99 |

> **Defeito intencional (BUG-01):** com `replaceCart: true`, os itens anteriores não são removidos. O carrinho fica com empresas diferentes.

## 8. `PATCH /users/:username/cart/items/:itemId` — Alterar quantidade

Regras: RN-10, RN-11.

**Corpo**

| Campo | Tipo | Obrigatório | Domínio |
|---|---|---|---|
| `quantity` | integer | Sim | 1 a 99 |

```json
{ "quantity": 3 }
```

**Resposta 200** — contrato `cart`.

**Erros**

| Status | Código | Causa |
|---|---|---|
| 400 | `VALIDATION_ERROR` | `quantity` ausente ou fora de 1 a 99 |
| 404 | `USER_NOT_FOUND` / `ITEM_NOT_FOUND` | Usuário ou item inexistente |

> **Defeito intencional (BUG-02):** a quantidade é gravada em dobro (`3` vira `6`).

## 9. `DELETE /users/:username/cart/items/:itemId` — Excluir item

Regra: RN-13. Sem corpo.

**Resposta 200** — contrato `cart`, sem o item excluído.

**Erros:** 404 `USER_NOT_FOUND` / `ITEM_NOT_FOUND`.

## 10. `POST /users/:username/cart/checkout` — Finalizar pedido

Regras: RN-14 a RN-16. Sem corpo. O carrinho não é alterado.

**Resposta 200** — contrato `checkout`

```json
{ "status": "READY_FOR_PAYMENT", "totalCents": 5290 }
```

**Erros**

| Status | Código | Causa |
|---|---|---|
| 404 | `USER_NOT_FOUND` | Usuário inexistente |
| 422 | `CART_EMPTY` | Carrinho vazio |
| 422 | `CART_MIXED_COMPANIES` | Itens de empresas diferentes |

> **Defeito intencional (BUG-03):** o carrinho com empresas diferentes não é recusado. A rota retorna 200.

## 11. `POST /users/:username/cart/pay` — Pagar

Regra: RN-17. Sem corpo. Pagamento simulado: em caso de sucesso, o carrinho é esvaziado.

**Resposta 200** — contrato `payment`

```json
{ "status": "PAID", "totalCents": 5290, "message": "Pagamento Fake efetuado" }
```

**Erros**

| Status | Código | Causa |
|---|---|---|
| 404 | `USER_NOT_FOUND` | Usuário inexistente |
| 422 | `CART_EMPTY` | Carrinho vazio |
| 422 | `CART_MIXED_COMPANIES` | Itens de empresas diferentes. O carrinho é mantido |

## Contratos

| Contrato | Arquivo | Usado por |
|---|---|---|
| `user` | `user.schema.json` | 1, 2, 3 |
| `companies` | `companies.schema.json` | 4 |
| `company` | `company.schema.json` | 5 e cada elemento de 4 |
| `cart` | `cart.schema.json` | 6, 7, 8, 9 |
| `checkout` | `checkout.schema.json` | 10 |
| `payment` | `payment.schema.json` | 11 |
| `error` | `error.schema.json` | Todas as respostas de erro |

Os cenários que validam os contratos estão na seção 10 do [repositório de testes de API](./REPOSITORIO_TESTES_API.md) (`CT-API-CON-001` a `028`, tag `@contract`).
