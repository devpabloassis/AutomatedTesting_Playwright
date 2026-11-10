# Repositório de Testes — API

> **Aviso:** este arquivo só existe porque nenhum repositório ou ferramenta de gestão de testes está integrado a este projeto. Ele é uma forma de **simular** que o repositório de testes existe em algum lugar.

| Campo | Valor |
|---|---|
| Sistema | Marketplace de Comida |
| Base | [`HISTORIA_DO_PRODUTO.md`](./HISTORIA_DO_PRODUTO.md) v1.0 |
| URL base | `http://127.0.0.1:3000/api` |
| Repositório relacionado | [`REPOSITORIO_TESTES_WEB.md`](./REPOSITORIO_TESTES_WEB.md) |

## 1. Convenções

- **Tipo:** `P` fluxo principal, `A` fluxo alternativo, `E` fluxo de exceção.
- **Resultado esperado:** sempre descreve o comportamento correto. Quando um defeito intencional impede esse resultado, a linha traz **Falha prevista** e o valor obtido.
- **Erro `ERRO`:** significa o status indicado, com corpo `{ "code": "ERRO", "message": "..." }`.
- **Tags:** todo cenário pertence também a `@api` e `@regression`. A coluna mostra as demais.
- **Massa:** cenários que alteram carrinho devem criar um usuário próprio com `POST /users`, para poderem rodar em paralelo. Os usuários pré-cadastrados são reservados aos cenários que os citam. `<user>` indica o usuário do cenário.

## 2. Tratamento de entrada

A API trata **somente o domínio dos caracteres e valores** de cada campo. Não existe filtro, escape ou bloqueio específico para SQL injection. Um payload malicioso é tratado como qualquer outro texto: é rejeitado quando viola o domínio do campo e, nos demais casos, segue a regra normal da rota.

| Campo | Domínio aceito | Fora do domínio |
|---|---|---|
| `username` (criação) | Texto de 3 a 30 caracteres, somente `A-Z`, `a-z`, `0-9` e `_` | 400 `VALIDATION_ERROR` |
| `password` (criação) | Texto com no mínimo 8 caracteres; qualquer caractere é aceito | 400 `VALIDATION_ERROR` |
| `username` e `password` (login) | Texto | 400 se não for texto; se for texto sem correspondência, 401 |
| `companyId`, `productId`, `optionId` | Valor exato do catálogo, diferenciando maiúsculas | 400 `VALIDATION_ERROR` |
| `quantity` | Número inteiro JSON de 1 a 99 | 400 `VALIDATION_ERROR` |
| `replaceCart` | Somente o booleano `true` confirma a troca | Outro valor equivale a não confirmar |
| Parâmetros de URL | Texto usado apenas na busca | 404 do recurso, sem correspondência |

## 3. Usuários

### 3.1 Criar usuário — `POST /users` (RN-18, RN-19)

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-USR-001 | Criar usuário válido | P | `username` e `password` válidos | 201 com `username` e `createdAt`, sem `password`, `salt` ou `hash` | `@smoke @feature_usuario` |
| CT-API-USR-002 | Nome com tamanho mínimo | A | `username` com 3 caracteres | 201 | `@feature_usuario` |
| CT-API-USR-003 | Nome com tamanho máximo | A | `username` com 30 caracteres | 201 | `@feature_usuario` |
| CT-API-USR-004 | Senha com tamanho mínimo | A | `password` com 8 caracteres | 201 | `@feature_usuario` |
| CT-API-USR-005 | Nome diferencia maiúsculas | A | Criar `Caso_X` e `caso_x` | 201 nas duas criações | `@feature_usuario` |
| CT-API-USR-006 | Nome já existente | E | Repetir um `username` | 409 `USER_ALREADY_EXISTS` | `@feature_usuario` |
| CT-API-USR-007 | Nome abaixo do mínimo | E | 2 caracteres | 400 `VALIDATION_ERROR` | `@feature_usuario` |
| CT-API-USR-008 | Nome acima do máximo | E | 31 caracteres | 400 `VALIDATION_ERROR` | `@feature_usuario` |
| CT-API-USR-009 | Senha abaixo do mínimo | E | 7 caracteres | 400 `VALIDATION_ERROR` | `@feature_usuario` |
| CT-API-USR-010 | Sem nome | E | Apenas `password` | 400 `VALIDATION_ERROR` | `@feature_usuario` |
| CT-API-USR-011 | Sem senha | E | Apenas `username` | 400 `VALIDATION_ERROR` | `@feature_usuario` |
| CT-API-USR-012 | Corpo vazio | E | Sem corpo | 400 `VALIDATION_ERROR` | `@feature_usuario` |
| CT-API-USR-013 | JSON malformado | E | `{"username":` | 400 `VALIDATION_ERROR` | `@feature_usuario` |
| CT-API-USR-014 | Corpo que não é objeto | E | `[]` | 400 `VALIDATION_ERROR` | `@feature_usuario` |
| CT-API-USR-015 | Corpo acima de 100 KB | E | JSON com mais de 100 KB | 400 `VALIDATION_ERROR` | `@feature_usuario` |

### 3.2 Consultar usuário — `GET /users/:username`

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-USR-020 | Consultar usuário existente | P | Usuário criado | 200 com `username` e `createdAt`, sem dados de senha | `@smoke @feature_usuario` |
| CT-API-USR-021 | Usuários pré-cadastrados existem | P | `user_manual`, `user_robot`, `user_hybrid`, `user_fail` | 200 para os quatro | `@smoke @feature_usuario` |
| CT-API-USR-022 | Usuário inexistente | E | Nome não cadastrado | 404 `USER_NOT_FOUND` | `@feature_usuario` |
| CT-API-USR-023 | Maiúsculas diferentes | E | `User_Manual` | 404 `USER_NOT_FOUND` | `@feature_usuario` |

## 4. Login — `POST /login` (RN-03)

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-LOG-001 | Credenciais válidas | P | Usuário e senha corretos | 200 com `username`, sem dados de senha | `@smoke @feature_login` |
| CT-API-LOG-002 | Login dos pré-cadastrados | P | Os 4 usuários com `loveMetalSongs@` | 200 para os quatro | `@smoke @feature_login` |
| CT-API-LOG-003 | Senha incorreta | E | Senha errada | 401 `INVALID_CREDENTIALS` | `@feature_login` |
| CT-API-LOG-004 | Usuário inexistente | E | Nome não cadastrado | 401 com a mesma mensagem de senha incorreta | `@feature_login` |
| CT-API-LOG-005 | Senha com maiúsculas diferentes | E | `LOVEMETALSONGS@` | 401 `INVALID_CREDENTIALS` | `@feature_login` |
| CT-API-LOG-006 | Sem usuário | E | Apenas `password` | 400 `VALIDATION_ERROR` | `@feature_login` |
| CT-API-LOG-007 | Sem senha | E | Apenas `username` | 400 `VALIDATION_ERROR` | `@feature_login` |
| CT-API-LOG-008 | Campos que não são texto | E | `username: 123`, `password: 123` | 400 `VALIDATION_ERROR` | `@feature_login` |

## 5. Catálogo

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-CAT-001 | Listar empresas | P | `GET /companies` | 200 com 4 empresas, cada uma com 4 produtos | `@smoke @feature_catalogo` |
| CT-API-CAT-002 | Preços do catálogo | P | Comparar com a seção 4 da história | Todos os valores em centavos correspondem | `@feature_catalogo` |
| CT-API-CAT-003 | Consultar cada empresa | P | `pizzaria`, `hamburgueria`, `japonesa`, `sucos` | 200 com a empresa solicitada | `@feature_catalogo` |
| CT-API-CAT-004 | Opções por tamanho | A | `pizzaria` e `sucos` | Produtos com opções `P`, `M` e `G` | `@feature_catalogo` |
| CT-API-CAT-005 | Opção única | A | `hamburgueria` e `japonesa` | Produtos somente com a opção `U` | `@feature_catalogo` |
| CT-API-CAT-006 | Empresa inexistente | E | `GET /companies/inexistente` | 404 `COMPANY_NOT_FOUND` | `@feature_catalogo` |
| CT-API-CAT-007 | Maiúsculas diferentes | E | `GET /companies/Pizzaria` | 404 `COMPANY_NOT_FOUND` | `@feature_catalogo` |

## 6. Carrinho

### 6.1 Consultar — `GET /users/:username/cart` (RN-04, RN-12)

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-CAR-001 | Carrinho vazio | P | Usuário novo | 200 com `items: []`, `companyIds: []`, `hasMixedCompanies: false`, `totalItems: 0`, `totalCents: 0` | `@smoke @feature_carrinho` |
| CT-API-CAR-002 | Carrinho com itens | P | 2 `portuguesa` `M` | 200 com dados do item, `subtotalCents: 10580`, `totalItems: 2`, `totalCents: 10580` | `@feature_carrinho` |
| CT-API-CAR-003 | Carrinhos independentes | A | Itens no usuário A; consultar B | Carrinho de B vazio | `@feature_carrinho` |
| CT-API-CAR-004 | Usuário inexistente | E | Nome não cadastrado | 404 `USER_NOT_FOUND` | `@feature_carrinho` |

### 6.2 Adicionar — `POST /users/:username/cart/items` (RN-05 a RN-10)

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-CAR-010 | Adicionar em carrinho vazio | P | `pizzaria/portuguesa/M`, `quantity: 1` | 201 com 1 item e `totalCents: 5290` | `@smoke @feature_carrinho` |
| CT-API-CAR-011 | Quantidade omitida | A | Sem `quantity` | 201 com quantidade 1 | `@feature_carrinho` |
| CT-API-CAR-012 | Outro produto da mesma empresa | A | 2 produtos de `pizzaria` | 201 com 2 itens | `@feature_carrinho` |
| CT-API-CAR-013 | Mesmo produto e opção | A | Adicionar `portuguesa/M` duas vezes | 201 com 1 item e quantidade 2 | `@feature_carrinho` |
| CT-API-CAR-014 | Mesmo produto, outra opção | A | `portuguesa/P` e `portuguesa/G` | 201 com 2 itens | `@feature_carrinho` |
| CT-API-CAR-015 | Quantidade máxima | A | `quantity: 99` | 201 com quantidade 99 | `@feature_carrinho` |
| CT-API-CAR-016 | Soma até o limite | A | 98 e depois 1 do mesmo item | 201 com quantidade 99 | `@feature_carrinho` |
| CT-API-CAR-017 | `replaceCart` com carrinho vazio | A | `replaceCart: true` | 201 com 1 item | `@feature_carrinho` |
| CT-API-CAR-018 | `replaceCart` na mesma empresa | A | Item de `pizzaria`, depois outro de `pizzaria` com `replaceCart: true` | 201 com 2 itens, sem troca de empresa | `@feature_carrinho` |
| CT-API-CAR-019 | Outra empresa sem confirmação | E | `pizzaria`, depois `hamburgueria` | 409 `CART_COMPANY_CONFLICT` e carrinho inalterado | `@smoke @feature_carrinho @feature_troca_empresa` |
| CT-API-CAR-020 | Outra empresa com confirmação | P | `pizzaria`, depois `hamburgueria` com `replaceCart: true` | 201 somente com o item de `hamburgueria`. **Falha prevista (BUG-01):** retorna os 2 itens e `hasMixedCompanies: true` | `@smoke @feature_carrinho @feature_troca_empresa @known_bug` |
| CT-API-CAR-021 | Soma acima do limite | E | 99 e depois 1 do mesmo item | 422 `QUANTITY_LIMIT_EXCEEDED` e quantidade 99 mantida | `@feature_carrinho` |
| CT-API-CAR-022 | Usuário inexistente | E | Nome não cadastrado | 404 `USER_NOT_FOUND` | `@feature_carrinho` |
| CT-API-CAR-023 | Empresa inexistente | E | `companyId: "x"` | 400 `VALIDATION_ERROR` | `@feature_carrinho` |
| CT-API-CAR-024 | Produto inexistente | E | `productId: "x"` | 400 `VALIDATION_ERROR` | `@feature_carrinho` |
| CT-API-CAR-025 | Opção inexistente | E | `optionId: "X"` | 400 `VALIDATION_ERROR` | `@feature_carrinho` |
| CT-API-CAR-026 | Produto de outra empresa | E | `pizzaria/duplo/U` | 400 `VALIDATION_ERROR` | `@feature_carrinho` |
| CT-API-CAR-027 | Opção `U` em produto com tamanho | E | `pizzaria/portuguesa/U` | 400 `VALIDATION_ERROR` | `@feature_carrinho` |
| CT-API-CAR-028 | Tamanho em produto de opção única | E | `hamburgueria/duplo/M` | 400 `VALIDATION_ERROR` | `@feature_carrinho` |
| CT-API-CAR-029 | Campos obrigatórios ausentes | E | Corpo `{}` | 400 `VALIDATION_ERROR` | `@feature_carrinho` |

### 6.3 Alterar quantidade — `PATCH /users/:username/cart/items/:itemId` (RN-10, RN-11)

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-CAR-030 | Alterar quantidade | P | `quantity: 3` | 200 com quantidade 3. **Falha prevista (BUG-02):** quantidade 6 | `@smoke @feature_carrinho @known_bug` |
| CT-API-CAR-031 | Quantidade mínima | A | `quantity: 1` | 200 com quantidade 1. **Falha prevista (BUG-02):** quantidade 2 | `@feature_carrinho @known_bug` |
| CT-API-CAR-032 | Quantidade máxima | A | `quantity: 99` | 200 com quantidade 99. **Falha prevista (BUG-02):** quantidade 198, violando a RN-10 | `@feature_carrinho @known_bug` |
| CT-API-CAR-033 | Recalcular valores | P | `portuguesa/M`, `quantity: 3` | `subtotalCents` e `totalCents` iguais a 15870, `totalItems: 3`. **Falha prevista (BUG-02):** 31740 e `totalItems: 6` | `@feature_carrinho @known_bug` |
| CT-API-CAR-034 | Quantidade zero | E | `quantity: 0` | 400 `VALIDATION_ERROR` e item inalterado | `@feature_carrinho` |
| CT-API-CAR-035 | Acima do máximo | E | `quantity: 100` | 400 `VALIDATION_ERROR` e item inalterado | `@feature_carrinho` |
| CT-API-CAR-036 | Quantidade negativa | E | `quantity: -1` | 400 `VALIDATION_ERROR` e item inalterado | `@feature_carrinho` |
| CT-API-CAR-037 | Quantidade ausente | E | Corpo `{}` | 400 `VALIDATION_ERROR` e item inalterado | `@feature_carrinho` |
| CT-API-CAR-038 | Item inexistente | E | `itemId` não cadastrado | 404 `ITEM_NOT_FOUND` | `@feature_carrinho` |
| CT-API-CAR-039 | Usuário inexistente | E | Nome não cadastrado | 404 `USER_NOT_FOUND` | `@feature_carrinho` |
| CT-API-CAR-040 | Item de outro usuário | E | `itemId` de A na rota de B | 404 `ITEM_NOT_FOUND` e item de A inalterado | `@feature_carrinho` |

### 6.4 Excluir — `DELETE /users/:username/cart/items/:itemId` (RN-13)

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-CAR-050 | Excluir um de vários itens | P | Carrinho com 2 itens | 200 com o item restante e total recalculado | `@smoke @feature_carrinho` |
| CT-API-CAR-051 | Excluir o último item | A | Carrinho com 1 item | 200 com carrinho vazio e `totalCents: 0` | `@feature_carrinho` |
| CT-API-CAR-052 | Item inexistente | E | `itemId` não cadastrado | 404 `ITEM_NOT_FOUND` | `@feature_carrinho` |
| CT-API-CAR-053 | Item já excluído | E | Excluir duas vezes | 404 `ITEM_NOT_FOUND` na segunda | `@feature_carrinho` |
| CT-API-CAR-054 | Usuário inexistente | E | Nome não cadastrado | 404 `USER_NOT_FOUND` | `@feature_carrinho` |
| CT-API-CAR-055 | Item de outro usuário | E | `itemId` de A na rota de B | 404 `ITEM_NOT_FOUND` e item de A mantido | `@feature_carrinho` |

## 7. Finalização e pagamento

`CT-API-PED-003` e `CT-API-PED-013` montam o carrinho misto com `replaceCart: true`, o que só é possível por causa do BUG-01. Quando esse defeito for corrigido, a pré-condição deixará de ser alcançável pela API.

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-PED-001 | Finalizar carrinho válido | P | Itens de uma empresa; `POST .../checkout` | 200 com `status: READY_FOR_PAYMENT`, total e carrinho mantido | `@smoke @feature_pedido` |
| CT-API-PED-002 | Finalizar carrinho vazio | E | Sem itens | 422 `CART_EMPTY` | `@feature_pedido` |
| CT-API-PED-003 | Finalizar com empresas diferentes | E | Carrinho misto | 422 `CART_MIXED_COMPANIES` com a mensagem da CA-06.2. **Falha prevista (BUG-03):** 200 com `status: READY_FOR_PAYMENT` | `@smoke @feature_pedido @known_bug` |
| CT-API-PED-004 | Finalizar duas vezes | A | Repetir com o carrinho válido | 200 nas duas | `@feature_pedido` |
| CT-API-PED-005 | Finalizar com usuário inexistente | E | Nome não cadastrado | 404 `USER_NOT_FOUND` | `@feature_pedido` |
| CT-API-PED-010 | Pagar carrinho válido | P | Depois de finalizar; `POST .../pay` | 200 com `status: PAID`, `message: Pagamento Fake efetuado` e carrinho vazio | `@smoke @feature_pagamento` |
| CT-API-PED-011 | Pagar sem finalizar antes | A | Carrinho válido, sem `checkout` | 200 com `status: PAID`, pois a API revalida o carrinho a cada pagamento | `@feature_pagamento` |
| CT-API-PED-012 | Pagar carrinho vazio | E | Sem itens | 422 `CART_EMPTY` | `@feature_pagamento` |
| CT-API-PED-013 | Pagar com empresas diferentes | E | Carrinho misto | 422 `CART_MIXED_COMPANIES` e carrinho mantido | `@feature_pagamento` |
| CT-API-PED-014 | Pagar duas vezes | E | Repetir após pagamento | 422 `CART_EMPTY` na segunda | `@feature_pagamento` |
| CT-API-PED-015 | Pagar com usuário inexistente | E | Nome não cadastrado | 404 `USER_NOT_FOUND` | `@feature_pagamento` |

## 8. Caracteres de domínio

### 8.1 `username` na criação

| ID | Cenário | Tipo | Valor enviado | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-DOM-001 | Somente minúsculas | A | `abcdef` | 201 | `@domain` |
| CT-API-DOM-002 | Somente maiúsculas | A | `ABCDEF` | 201 | `@domain` |
| CT-API-DOM-003 | Somente números | A | `123456` | 201 | `@domain` |
| CT-API-DOM-004 | Somente sublinhado | A | `___` | 201 | `@domain` |
| CT-API-DOM-005 | Combinação válida | P | `Ab_12` | 201 | `@domain` |
| CT-API-DOM-010 | Texto vazio | E | Texto vazio | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-011 | Espaço interno | E | `ana maria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-012 | Espaço no início | E | ` anamaria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-013 | Espaço no fim | E | `anamaria ` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-014 | Quebra de linha no fim | E | `anamaria` seguido de `\n` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-015 | Tabulação | E | `ana` `\t` `maria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-016 | Hífen | E | `ana-maria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-017 | Ponto | E | `ana.maria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-018 | Arroba | E | `ana@maria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-019 | Acento | E | `joão` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-020 | Cedilha | E | `cauçao` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-021 | Emoji | E | `ana😀` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-022 | Aspas simples | E | `ana'maria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-023 | Aspas duplas | E | `ana"maria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-024 | Ponto e vírgula | E | `ana;maria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-025 | Porcentagem | E | `ana%maria` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-026 | Barras | E | `ana/maria\x` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-027 | Marcação HTML | E | `<b>ana</b>` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-028 | Tipo número | E | `123456` sem aspas | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-029 | Tipo nulo | E | `null` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-030 | Tipo lista | E | `["ana_maria"]` | 400 `VALIDATION_ERROR` | `@domain` |

### 8.2 `password` na criação

| ID | Cenário | Tipo | Valor enviado | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-DOM-040 | Símbolos | A | `!@#$%^&*()` | 201, e o login com a mesma senha retorna 200 | `@domain` |
| CT-API-DOM-041 | Acentos e cedilha | A | `açãoÉótima` | 201, e o login com a mesma senha retorna 200 | `@domain` |
| CT-API-DOM-042 | Espaços | A | `senha com espaco` | 201, e o login com a mesma senha retorna 200 | `@domain` |
| CT-API-DOM-043 | Emoji | A | `senha😀😀😀😀` | 201, e o login com a mesma senha retorna 200 | `@domain` |
| CT-API-DOM-044 | Tipo número | E | `12345678` sem aspas | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-045 | Tipo nulo | E | `null` | 400 `VALIDATION_ERROR` | `@domain` |

### 8.3 `quantity`

Cada valor deve ser enviado em `POST .../cart/items` e, quando indicado, em `PATCH .../cart/items/:itemId`.

| ID | Cenário | Tipo | Valor enviado | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-DOM-050 | Texto numérico | E | `"3"`, em POST e PATCH | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-051 | Decimal | E | `1.5`, em POST e PATCH | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-052 | Texto com letras | E | `"abc"`, em POST e PATCH | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-053 | Símbolo | E | `"!"`, em POST e PATCH | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-054 | Booleano | E | `true`, em POST e PATCH | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-055 | Nulo | E | `null`, em POST e PATCH | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-056 | Lista | E | `[1]`, em POST e PATCH | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-057 | Objeto | E | `{}`, em POST e PATCH | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-058 | Notação científica válida | A | `1e1`, em POST | 201 com quantidade 10, pois o JSON representa o inteiro 10 | `@domain` |
| CT-API-DOM-059 | Notação científica acima do limite | E | `1e2`, em POST | 400 `VALIDATION_ERROR` | `@domain` |

### 8.4 Identificadores do catálogo

| ID | Cenário | Tipo | Valor enviado | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-DOM-060 | `companyId` em maiúsculas | E | `PIZZARIA` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-061 | `productId` em maiúsculas | E | `PORTUGUESA` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-062 | `optionId` em minúscula | E | `m` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-063 | Espaço em `companyId` | E | `pizzaria ` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-064 | Espaço em `optionId` | E | ` M` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-065 | Acento em `productId` | E | `portuguêsa` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-066 | Tipo número | E | `companyId: 1` | 400 `VALIDATION_ERROR` | `@domain` |
| CT-API-DOM-067 | Tipo nulo | E | `optionId: null` | 400 `VALIDATION_ERROR` | `@domain` |

### 8.5 `replaceCart` e parâmetros de URL

| ID | Cenário | Tipo | Valor enviado | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-DOM-070 | `replaceCart` como texto | E | `"true"`, com conflito de empresa | 409 `CART_COMPANY_CONFLICT` | `@domain` |
| CT-API-DOM-071 | `replaceCart` como número | E | `1`, com conflito de empresa | 409 `CART_COMPANY_CONFLICT` | `@domain` |
| CT-API-DOM-072 | `replaceCart` nulo | E | `null`, com conflito de empresa | 409 `CART_COMPANY_CONFLICT` | `@domain` |
| CT-API-DOM-073 | `replaceCart` falso | A | `false`, com conflito de empresa | 409 `CART_COMPANY_CONFLICT` | `@domain` |
| CT-API-DOM-074 | Acento na URL | E | `GET /users/jo%C3%A3o` | 404 `USER_NOT_FOUND` | `@domain` |
| CT-API-DOM-075 | Espaço na URL | E | `GET /users/ana%20maria` | 404 `USER_NOT_FOUND` | `@domain` |
| CT-API-DOM-076 | Codificação inválida na URL | E | `GET /users/%E0%A4%A` | 400 `VALIDATION_ERROR` | `@domain` |

## 9. SQL injection

Cada cenário deve ser executado com **todos** os payloads abaixo. Eles funcionam como massa de um teste orientado a dados. Os valores são enviados como JSON ou, em parâmetros de URL, com codificação percentual.

| ID | Payload |
|---|---|
| SQL-01 | `' OR '1'='1` |
| SQL-02 | `' OR 1=1--` |
| SQL-03 | `admin'--` |
| SQL-04 | `'; DROP TABLE users;--` |
| SQL-05 | `" OR ""="` |
| SQL-06 | `' UNION SELECT username, password FROM users--` |
| SQL-07 | `1; SELECT pg_sleep(5)--` |
| SQL-08 | `') OR ('1'='1` |

| ID | Cenário | Tipo | Campo | Resultado esperado | Motivo | Tags |
|---|---|---|---|---|---|---|
| CT-API-SQL-001 | Criar usuário | E | `username` | 400 `VALIDATION_ERROR` e usuário não criado | Viola o domínio do campo | `@security @sqli` |
| CT-API-SQL-002 | Criar usuário | A | `password` | 201; a resposta não contém a senha | A senha aceita qualquer caractere | `@security @sqli` |
| CT-API-SQL-003 | Login com senha igual ao payload | A | `password` | 200 somente para o usuário criado em `CT-API-SQL-002` com esse mesmo texto | O payload é uma senha comum | `@security @sqli` |
| CT-API-SQL-004 | Login | E | `username`, com senha correta de `user_manual` | 401 `INVALID_CREDENTIALS` | Não há usuário com esse nome | `@security @sqli @feature_login` |
| CT-API-SQL-005 | Login | E | `password` de `user_manual` | 401 `INVALID_CREDENTIALS` | A senha não confere | `@security @sqli @feature_login` |
| CT-API-SQL-006 | Consultar usuário | E | `:username` | 404 `USER_NOT_FOUND`, sem retornar outros usuários | Sem correspondência | `@security @sqli` |
| CT-API-SQL-007 | Consultar empresa | E | `:companyId` | 404 `COMPANY_NOT_FOUND` | Sem correspondência | `@security @sqli` |
| CT-API-SQL-008 | Consultar carrinho | E | `:username` | 404 `USER_NOT_FOUND`, sem retornar itens de outros usuários | Sem correspondência | `@security @sqli` |
| CT-API-SQL-009 | Adicionar item | E | `companyId` | 400 `VALIDATION_ERROR` e carrinho inalterado | Fora do catálogo | `@security @sqli` |
| CT-API-SQL-010 | Adicionar item | E | `productId` | 400 `VALIDATION_ERROR` e carrinho inalterado | Fora do catálogo | `@security @sqli` |
| CT-API-SQL-011 | Adicionar item | E | `optionId` | 400 `VALIDATION_ERROR` e carrinho inalterado | Fora do catálogo | `@security @sqli` |
| CT-API-SQL-012 | Adicionar item | E | `quantity` | 400 `VALIDATION_ERROR` e carrinho inalterado | Não é inteiro | `@security @sqli` |
| CT-API-SQL-013 | Adicionar item com conflito | E | `replaceCart` | 409 `CART_COMPANY_CONFLICT` e carrinho inalterado | Não é o booleano `true` | `@security @sqli` |
| CT-API-SQL-014 | Alterar item | E | `quantity` | 400 `VALIDATION_ERROR` e item inalterado | Não é inteiro | `@security @sqli` |
| CT-API-SQL-015 | Alterar item | E | `:itemId` | 404 `ITEM_NOT_FOUND` e item real inalterado | Sem correspondência | `@security @sqli` |
| CT-API-SQL-016 | Excluir item | E | `:itemId` | 404 `ITEM_NOT_FOUND` e item real mantido | Sem correspondência | `@security @sqli` |
| CT-API-SQL-017 | Finalizar e pagar | E | `:username` | 404 `USER_NOT_FOUND` nas duas rotas | Sem correspondência | `@security @sqli` |
| CT-API-SQL-018 | Integridade depois dos ataques | P | — | Os 4 usuários pré-cadastrados continuam consultáveis e fazendo login | Nenhum dado foi afetado | `@security @sqli @smoke` |

## 10. Contrato

Os cenários validam a resposta contra os JSON Schemas de `automated_testing/contracts/`, descritos em [`API_ENDPOINTS.md`](./API_ENDPOINTS.md). Todos têm a tag `@contract`.

A resposta segue o contrato quando tem todos os campos obrigatórios, com o tipo e o formato definidos, e **nenhum campo a mais**. Em caso de falha, o teste lista cada violação, por exemplo `[0].commissionPercent: campo não previsto no contrato`.

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-CON-001 | Criar usuário | P | `POST /users` válido | 201 no contrato `user` | `@smoke @feature_usuario` |
| CT-API-CON-002 | Erro de validação ao criar usuário | E | `username` com 2 caracteres | 400 no contrato `error` | `@feature_usuario` |
| CT-API-CON-003 | Usuário já existente | E | `username` já cadastrado | 409 no contrato `error` | `@feature_usuario` |
| CT-API-CON-004 | Consultar usuário | P | `GET /users/<user>` | 200 no contrato `user` | `@feature_usuario` |
| CT-API-CON-005 | Usuário inexistente | E | `GET /users/` com nome não cadastrado | 404 no contrato `error` | `@feature_usuario` |
| CT-API-CON-006 | Login válido | P | `user_manual` com a senha correta | 200 no contrato `user` | `@smoke @feature_login` |
| CT-API-CON-007 | Login inválido | E | Senha incorreta | 401 no contrato `error` | `@feature_login` |
| CT-API-CON-008 | Listar empresas | P | `GET /companies` | 200 no contrato `companies`, sem campos a mais. **Falha prevista (BUG-04):** cada empresa traz `commissionPercent` | `@smoke @feature_catalogo @known_bug` |
| CT-API-CON-009 | Consultar empresa | P | `GET /companies/pizzaria` | 200 no contrato `company` | `@feature_catalogo` |
| CT-API-CON-010 | Empresa inexistente | E | `GET /companies/inexistente` | 404 no contrato `error` | `@feature_catalogo` |
| CT-API-CON-011 | Carrinho vazio | P | `GET /users/<user>/cart` | 200 no contrato `cart` | `@feature_carrinho` |
| CT-API-CON-012 | Carrinho com itens | P | Carrinho com 2 itens | 200 no contrato `cart`, incluindo cada item | `@smoke @feature_carrinho` |
| CT-API-CON-013 | Carrinho de usuário inexistente | E | `GET /users/<inexistente>/cart` | 404 no contrato `error` | `@feature_carrinho` |
| CT-API-CON-014 | Adicionar item | P | `POST /cart/items` válido | 201 no contrato `cart` | `@feature_carrinho` |
| CT-API-CON-015 | Item inválido | E | Opção `U` para `laranja` | 400 no contrato `error` | `@feature_carrinho` |
| CT-API-CON-016 | Conflito de empresa | E | Item de outra empresa sem `replaceCart` | 409 no contrato `error` | `@feature_troca_empresa` |
| CT-API-CON-017 | Limite de quantidade | E | Item com 99 unidades; adicionar mais 1 | 422 no contrato `error` | `@feature_carrinho` |
| CT-API-CON-018 | Alterar quantidade | P | `PATCH` com `quantity` 2 | 200 no contrato `cart` | `@feature_carrinho` |
| CT-API-CON-019 | Alterar item inexistente | E | `PATCH` em `:itemId` inexistente | 404 no contrato `error` | `@feature_carrinho` |
| CT-API-CON-020 | Excluir item | P | `DELETE` de item existente | 200 no contrato `cart` | `@feature_carrinho` |
| CT-API-CON-021 | Excluir item inexistente | E | `DELETE` em `:itemId` inexistente | 404 no contrato `error` | `@feature_carrinho` |
| CT-API-CON-022 | Finalizar pedido | P | `POST /cart/checkout` com 1 item | 200 no contrato `checkout` | `@smoke @feature_pedido` |
| CT-API-CON-023 | Finalizar carrinho vazio | E | `POST /cart/checkout` sem itens | 422 no contrato `error` | `@feature_pedido` |
| CT-API-CON-024 | Pagar pedido | P | `POST /cart/pay` com 1 item | 200 no contrato `payment` | `@smoke @feature_pagamento` |
| CT-API-CON-025 | Pagar com empresas diferentes | E | Carrinho misto, gerado pelo BUG-01 | 422 no contrato `error` | `@feature_pagamento` |
| CT-API-CON-026 | Rota inexistente | E | `GET /inexistente` | 404 no contrato `error` | — |
| CT-API-CON-027 | Método não permitido | E | `DELETE /users` | 405 no contrato `error` | — |
| CT-API-CON-028 | JSON inválido | E | Corpo com JSON malformado | 400 no contrato `error` | — |

## 11. Requisições e persistência

| ID | Cenário | Tipo | Entrada | Resultado esperado | Tags |
|---|---|---|---|---|---|
| CT-API-GER-001 | Resposta em JSON | P | Qualquer rota da API | Cabeçalho `Content-Type` com `application/json` | `@smoke` |
| CT-API-GER-002 | Rota inexistente | E | `GET /inexistente` | 404 `NOT_FOUND` | — |
| CT-API-GER-003 | Método não permitido | E | `DELETE /users` | 405 `METHOD_NOT_ALLOWED` | — |
| CT-API-GER-010 | Dados mantidos ao reiniciar | P | Criar usuário e item; reiniciar o servidor | Usuário e carrinho continuam disponíveis | `@persistence` |
| CT-API-GER-011 | Reinício não duplica nem altera pré-cadastrados | A | Reiniciar o servidor | Os 4 usuários continuam únicos, com o mesmo `createdAt` | `@persistence` |
| CT-API-GER-012 | Senha não gravada em texto puro | P | Criar usuário; inspecionar `application/data/db.json` | A senha informada não aparece no arquivo | `@security @persistence` |

## 12. Execução por tags

| Objetivo | Comando previsto |
|---|---|
| Fumaça da API | `npx playwright test --project=api --grep @smoke` |
| Domínio | `npx playwright test --project=api --grep @domain` |
| SQL injection | `npx playwright test --project=api --grep @sqli` |
| Contrato | `npx playwright test --project=api --grep @contract` |
| Carrinho | `npx playwright test --project=api --grep @feature_carrinho` |
| Sem defeitos conhecidos | `npx playwright test --project=api --grep-invert @known_bug` |
