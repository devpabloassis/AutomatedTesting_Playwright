# História do Produto — Marketplace de Comida

| Campo | Valor |
|---|---|
| Produto | Marketplace de Comida (sistema-alvo para automação de testes) |
| Versão do documento | 1.0 |
| Data | 09/11/2026 |
| Público | Produto, desenvolvimento e QA |
| Status | Aprovado para construção |

## 1. Visão geral

O Marketplace de Comida é uma aplicação web em que o cliente navega por empresas de alimentação, escolhe produtos, monta um carrinho de **uma única empresa** e conclui um pedido com pagamento simulado.

O produto existe para servir de alvo a testes automatizados de Web e API. Por isso, ele contém **defeitos intencionais**, descritos na seção 10. As seções 3 a 9 descrevem sempre o **comportamento correto esperado**: é esse o comportamento que os testes devem validar.

## 2. Escopo

### 2.1 Incluído

- Criação e consulta de usuários via API.
- Login na interface, validado pela API.
- Navegação pública por empresas e produtos.
- Carrinho por usuário: inclusão, alteração de quantidade e exclusão de itens.
- Controle de carrinho de uma única empresa.
- Finalização do pedido e pagamento simulado.
- Persistência em arquivo JSON local.

### 2.2 Fora de escopo

- Tela de cadastro de usuário (a criação é feita somente pela API).
- Pagamento real, entrega e histórico de pedidos.
- Administração do catálogo (os produtos são fixos no código).
- Controle de autorização nas rotas de API. Não há token de sessão e o sistema deve rodar apenas em ambiente local.

## 3. Perfis

| Perfil | Descrição | Permissões |
|---|---|---|
| Visitante | Pessoa sem login | Ver empresas e produtos |
| Cliente | Pessoa autenticada | Tudo que o visitante faz, além de usar o carrinho, finalizar o pedido e pagar |

### 3.1 Usuários pré-cadastrados

Sempre que o sistema inicia, ele garante a existência dos usuários abaixo. A operação não duplica registros nem altera usuários já existentes.

| Usuário | Senha |
|---|---|
| `user_manual` | `loveMetalSongs@` |
| `user_robot` | `loveMetalSongs@` |
| `user_hybrid` | `loveMetalSongs@` |
| `user_fail` | `loveMetalSongs@` |

## 4. Catálogo

O catálogo é fixo no código. Produtos sem variação de tamanho têm uma única opção, chamada "Único".

### 4.1 Pizzaria Forno Nobre (`pizzaria`)

| Produto | Pequeno | Médio | Grande |
|---|---:|---:|---:|
| Portuguesa | R$ 38,90 | R$ 52,90 | R$ 66,90 |
| Calabresa | R$ 34,90 | R$ 48,90 | R$ 62,90 |
| Frango com Catupiry | R$ 36,90 | R$ 50,90 | R$ 64,90 |
| Marguerita | R$ 32,90 | R$ 46,90 | R$ 60,90 |

### 4.2 Hamburgueria Chapa Quente (`hamburgueria`)

| Produto | Preço |
|---|---:|
| Vegano | R$ 31,90 |
| Completo | R$ 29,90 |
| Eggburguer | R$ 26,90 |
| Duplo | R$ 36,90 |

### 4.3 Japa Express (`japonesa`)

| Produto | Preço |
|---|---:|
| Yakissoba de Carne | R$ 34,90 |
| Yakissoba de Frango | R$ 31,90 |
| Yakissoba Misto | R$ 37,90 |
| Hot Filadélfia | R$ 29,90 |

### 4.4 Sucos da Fruta (`sucos`)

| Produto | Pequeno | Médio | Grande |
|---|---:|---:|---:|
| Laranja | R$ 8,90 | R$ 11,90 | R$ 14,90 |
| Abacaxi | R$ 9,90 | R$ 12,90 | R$ 15,90 |
| Goiaba | R$ 9,50 | R$ 12,50 | R$ 15,50 |
| Acerola | R$ 9,00 | R$ 12,00 | R$ 15,00 |

## 5. Regras de negócio

| ID | Regra |
|---|---|
| RN-01 | Empresas e produtos podem ser vistos sem login. |
| RN-02 | Somente um cliente autenticado pode usar o carrinho. Ao tentar adicionar um produto sem login, o visitante é levado ao login e retorna à empresa depois de entrar. |
| RN-03 | O login só é concedido depois que a API valida usuário e senha. |
| RN-04 | Cada usuário tem um único carrinho, independente dos demais. |
| RN-05 | O carrinho só pode conter produtos de uma empresa. |
| RN-06 | Ao adicionar um produto de outra empresa, a aplicação avisa que continuar limpará o carrinho e pede confirmação. |
| RN-07 | Ao confirmar com **Sim**, todos os itens anteriores são removidos e somente o novo produto permanece no carrinho. |
| RN-08 | Ao escolher **Não**, o carrinho permanece inalterado e o produto não é adicionado. |
| RN-09 | Adicionar novamente o mesmo produto, na mesma opção, soma a quantidade ao item existente. |
| RN-10 | A quantidade informada deve ser um número inteiro de 1 a 99. A quantidade total de um item não pode passar de 99. |
| RN-11 | Ao alterar a quantidade, o item passa a ter exatamente o valor informado. |
| RN-12 | O subtotal do item é o preço unitário multiplicado pela quantidade. O total é a soma dos subtotais. |
| RN-13 | Um item pode ser excluído do carrinho a qualquer momento antes do pagamento. |
| RN-14 | Um carrinho vazio não pode ser finalizado. |
| RN-15 | Um carrinho com itens de mais de uma empresa não pode ser finalizado. O backend recusa a conclusão do pedido e a interface exibe a mensagem retornada. |
| RN-16 | Depois de uma finalização bem-sucedida, a mensagem `Pedido Concluído` é exibida junto com o botão **Pagar**, que só aparece nessa condição. Qualquer alteração posterior no carrinho exige nova finalização. |
| RN-17 | Depois do pagamento, a mensagem `Pagamento Fake efetuado` é exibida e o carrinho fica vazio. |
| RN-18 | O nome de usuário é único, tem de 3 a 30 caracteres e aceita letras, números e `_`. A senha tem no mínimo 8 caracteres. |
| RN-19 | As senhas não são gravadas em texto puro nem retornadas pela API. |

## 6. Histórias de usuário e critérios de aceite

### US-01 — Navegar sem login

**Como** visitante, **quero** ver empresas e produtos **para** conhecer as opções antes de entrar.

- **CA-01.1:** a página inicial exibe as 4 empresas.
- **CA-01.2:** ao entrar em uma empresa, seus 4 produtos são exibidos com opções e preços.
- **CA-01.3:** ao selecionar um tamanho, o preço exibido corresponde a esse tamanho.
- **CA-01.4:** ao clicar em **Adicionar ao carrinho** sem login, o visitante é direcionado ao login, sem que nada seja adicionado.

### US-02 — Fazer login

**Como** cliente, **quero** entrar com usuário e senha **para** usar meu carrinho.

- **CA-02.1:** com credenciais válidas, o nome do usuário aparece no cabeçalho.
- **CA-02.2:** com credenciais inválidas, a mensagem `Usuário ou senha inválidos.` é exibida e o login não é concedido.
- **CA-02.3:** a sessão permanece ao recarregar a página.
- **CA-02.4:** ao clicar em **Sair**, a sessão é encerrada.

### US-03 — Adicionar produtos

**Como** cliente, **quero** adicionar produtos ao carrinho **para** montar meu pedido.

- **CA-03.1:** com carrinho vazio, o produto é adicionado com quantidade 1.
- **CA-03.2:** adicionar outro produto da mesma empresa não exibe aviso.
- **CA-03.3:** adicionar o mesmo produto e opção soma 1 à quantidade do item.
- **CA-03.4:** o contador do cabeçalho mostra a soma das quantidades do carrinho.

### US-04 — Trocar de empresa

**Como** cliente, **quero** ser avisado ao escolher produto de outra empresa **para** decidir se troco o pedido.

```gherkin
Dado que tenho itens da "Pizzaria Forno Nobre" no carrinho
Quando adiciono um produto da "Hamburgueria Chapa Quente"
Então vejo o aviso de que continuar limpará o carrinho
E vejo as opções "Sim" e "Não"

Quando escolho "Sim"
Então os itens da pizzaria são removidos
E o carrinho contém somente o produto da hamburgueria

Quando escolho "Não"
Então o carrinho continua somente com os itens da pizzaria
```

### US-05 — Gerenciar o carrinho

**Como** cliente, **quero** alterar e excluir itens **para** ajustar meu pedido.

- **CA-05.1:** o carrinho exibe empresa, produto, opção, preço unitário, quantidade e subtotal.
- **CA-05.2:** ao informar uma quantidade válida e clicar em **Atualizar**, o item passa a ter exatamente a quantidade informada.
- **CA-05.3:** subtotal, total e contador do cabeçalho são recalculados após a alteração.
- **CA-05.4:** quantidade inválida é rejeitada e o item permanece inalterado.
- **CA-05.5:** ao clicar em **Excluir**, o item sai do carrinho e o total é recalculado.

### US-06 — Finalizar o pedido

**Como** cliente, **quero** finalizar o carrinho **para** seguir ao pagamento.

- **CA-06.1:** com carrinho de uma única empresa, **Finalizar pedido** exibe `Pedido Concluído` e libera o botão **Pagar**.
- **CA-06.2:** com itens de mais de uma empresa, o backend recusa a conclusão e é exibida a mensagem `Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido.` e **Pagar** não aparece.
- **CA-06.3:** alterar ou excluir um item após a finalização oculta o botão **Pagar**.

### US-07 — Pagar

**Como** cliente, **quero** pagar o pedido **para** concluir a compra.

- **CA-07.1:** ao clicar em **Pagar**, é exibida a mensagem `Pagamento Fake efetuado`.
- **CA-07.2:** após o pagamento, o carrinho fica vazio e o contador mostra 0.
- **CA-07.3:** com itens de mais de uma empresa, o pagamento é recusado pelo backend, a mensagem de empresas diferentes é exibida e os itens permanecem no carrinho.

## 7. Fluxo principal

```text
Visitante ou Cliente
   └─ Página inicial ─ escolhe empresa ─ escolhe produto e opção ─ Adicionar ao carrinho
         ├─ sem login ─────────────────── Login ─ retorna à empresa
         ├─ carrinho vazio ou mesma empresa ─ produto adicionado
         └─ outra empresa ─ aviso de limpeza
                ├─ Não ─ carrinho inalterado
                └─ Sim ─ carrinho limpo ─ produto da nova empresa adicionado

Carrinho ─ alterar/excluir itens ─ Finalizar pedido
         ├─ vazio ou empresas diferentes ─ mensagem de bloqueio
         └─ válido ─ "Pedido Concluído" ─ botão Pagar ─ "Pagamento Fake efetuado" ─ carrinho vazio
```

## 8. Interface

| Rota | Tela | Acesso |
|---|---|---|
| `/` | Lista de empresas | Público |
| `/empresas/:companyId` | Produtos da empresa | Público |
| `/login` | Login | Público |
| `/carrinho` | Carrinho, finalização e pagamento | Cliente |

Todo elemento usado na automação tem um `id` único. Nos elementos repetidos, o `id` inclui o identificador do item. O projeto de testes concentra esses seletores no mapa de objetos `automated_testing/support/object-map.ts`.

| Tela | Elemento | `id` |
|---|---|---|
| Todas | Título e subtítulo | `page-title`, `page-subtitle` |
| Todas | Mensagem da tela | `message` |
| Todas | Link de retorno em página não encontrada | `back-to-companies` |
| Cabeçalho | Marca, link e contador do carrinho | `header-brand`, `header-cart-link`, `cart-count` |
| Cabeçalho | Usuário logado, **Sair** e **Entrar** | `logged-user`, `logout-button`, `login-link` |
| Inicial | Lista de empresas | `company-list` |
| Inicial | Cartão, nome e descrição da empresa | `company-<companyId>`, `company-<companyId>-name`, `company-<companyId>-description` |
| Empresa | Lista de produtos | `product-list` |
| Empresa | Cartão, nome e preço do produto | `product-<productId>`, `product-<productId>-name`, `product-<productId>-price` |
| Empresa | Tamanho e **Adicionar ao carrinho** | `product-<productId>-size`, `product-<productId>-add` |
| Empresa | Aviso de troca de empresa | `confirm-dialog`, `confirm-title`, `confirm-text`, `confirm-yes`, `confirm-no` |
| Login | Formulário, usuário, senha e **Entrar** | `login-form`, `login-username`, `login-password`, `login-submit` |
| Carrinho | Carrinho vazio e **Ver empresas** | `cart-empty-message`, `cart-view-companies` |
| Carrinho | Carrinho sem login e **Entrar** | `cart-login-message`, `cart-login-button` |
| Carrinho | Lista de itens | `cart-list` |
| Carrinho | Linha do item | `cart-item-<productId>-<optionId>` |
| Carrinho | Nome, empresa e opção, preço unitário e subtotal | `<linha>-name`, `<linha>-details`, `<linha>-unit-price`, `<linha>-subtotal` |
| Carrinho | Quantidade, **Atualizar** e **Excluir** | `<linha>-quantity`, `<linha>-update`, `<linha>-delete` |
| Carrinho | Total, **Finalizar pedido** e **Pagar** | `cart-total`, `checkout-button`, `pay-button` |

`<linha>` representa o `id` da linha do item, por exemplo `cart-item-portuguesa-M`.

## 9. API

Base: `http://localhost:3000/api`. Requisições e respostas usam JSON. Os erros têm o formato `{ "code": "CODIGO", "message": "Descrição" }`. Valores monetários são retornados em centavos. A documentação completa de cada endpoint, com exemplos e contratos, está em [`API_ENDPOINTS.md`](./API_ENDPOINTS.md).

| Método | Rota | Finalidade | Sucesso | Erros |
|---|---|---|---|---|
| POST | `/users` | Criar usuário | 201 | 400 `VALIDATION_ERROR`, 409 `USER_ALREADY_EXISTS` |
| GET | `/users/:username` | Consultar usuário | 200 | 404 `USER_NOT_FOUND` |
| POST | `/login` | Validar credenciais | 200 | 400 `VALIDATION_ERROR`, 401 `INVALID_CREDENTIALS` |
| GET | `/companies` | Listar catálogo | 200 | — |
| GET | `/companies/:companyId` | Consultar empresa | 200 | 404 `COMPANY_NOT_FOUND` |
| GET | `/users/:username/cart` | Consultar carrinho | 200 | 404 `USER_NOT_FOUND` |
| POST | `/users/:username/cart/items` | Adicionar item | 201 | 400, 404, 409 `CART_COMPANY_CONFLICT`, 422 `QUANTITY_LIMIT_EXCEEDED` |
| PATCH | `/users/:username/cart/items/:itemId` | Alterar quantidade | 200 | 400, 404 `ITEM_NOT_FOUND` |
| DELETE | `/users/:username/cart/items/:itemId` | Excluir item | 200 | 404 `ITEM_NOT_FOUND` |
| POST | `/users/:username/cart/checkout` | Finalizar pedido | 200 | 422 `CART_EMPTY`, 422 `CART_MIXED_COMPANIES` |
| POST | `/users/:username/cart/pay` | Pagar | 200 | 422 `CART_EMPTY`, 422 `CART_MIXED_COMPANIES` |

Exemplos de corpo:

```jsonc
// POST /users
{ "username": "novo_usuario", "password": "senhaSegura1" }

// POST /login
{ "username": "user_manual", "password": "loveMetalSongs@" }

// POST /users/:username/cart/items
// replaceCart: true confirma a troca de empresa e deve limpar o carrinho (RN-07)
{ "companyId": "pizzaria", "productId": "portuguesa", "optionId": "M", "quantity": 1, "replaceCart": false }

// PATCH /users/:username/cart/items/:itemId
{ "quantity": 3 }
```

Os identificadores de opção são `P`, `M` e `G` para produtos com tamanho, e `U` para opção única.

Os dados ficam em `application/data/db.json`. Cada gravação substitui o arquivo de forma atômica.

## 10. Defeitos intencionais

> Os defeitos abaixo foram inseridos de propósito e **não devem ser corrigidos**. Eles existem para que os testes automatizados falhem nos pontos previstos. No código, estão identificados pelos comentários `DEFEITO INTENCIONAL`.

### BUG-01 — Carrinho não é limpo ao trocar de empresa

| Campo | Descrição |
|---|---|
| Regra violada | RN-07 / US-04 |
| Severidade | Alta |
| Camada | API: `POST /users/:username/cart/items` com `replaceCart: true` |
| Passos | 1. Entrar e adicionar um produto de uma empresa. 2. Abrir outra empresa e adicionar um produto. 3. Clicar em **Sim** no aviso. |
| Resultado esperado | Somente o produto da nova empresa permanece no carrinho. |
| Resultado obtido | O carrinho mantém os itens anteriores e também recebe o novo produto. O contador do cabeçalho mostra a soma das quantidades desse carrinho: com 1 item anterior, passa de 1 para 2 em vez de mostrar 1. |

### BUG-02 — Quantidade é duplicada ao alterar item

| Campo | Descrição |
|---|---|
| Regra violada | RN-11 / CA-05.2 |
| Severidade | Alta |
| Camada | API: `PATCH /users/:username/cart/items/:itemId` |
| Passos | 1. Adicionar um produto. 2. No carrinho, informar a quantidade 3. 3. Clicar em **Atualizar**. |
| Resultado esperado | O item fica com quantidade 3. |
| Resultado obtido | O item fica com quantidade 6, e subtotal, total e contador refletem esse valor. |

### BUG-03 — Pedido com empresas diferentes é concluído

| Campo | Descrição |
|---|---|
| Regra violada | RN-15 / CA-06.2 |
| Severidade | Alta |
| Camada | API: `POST /users/:username/cart/checkout` |
| Passos | 1. Montar um carrinho com itens de duas empresas. 2. Clicar em **Finalizar pedido**. |
| Resultado esperado | O backend retorna 422 `CART_MIXED_COMPANIES`, a mensagem `Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido.` é exibida e **Pagar** não aparece. |
| Resultado obtido | O backend retorna 200, a mensagem `Pedido Concluído` é exibida e o botão **Pagar** aparece. |

### BUG-04 — Listagem de empresas fora do contrato

| Campo | Descrição |
|---|---|
| Regra violada | Contrato `companies` (ver [`API_ENDPOINTS.md`](./API_ENDPOINTS.md)) |
| Severidade | Média |
| Camada | API: `GET /companies` |
| Passos | 1. Chamar `GET /companies`. 2. Comparar cada empresa com o contrato. |
| Resultado esperado | Cada empresa traz somente `id`, `name`, `description` e `products`. |
| Resultado obtido | Cada empresa também traz o campo interno `commissionPercent`, que não está no contrato. A consulta de uma empresa (`GET /companies/:companyId`) não tem o defeito. |

### Efeitos observáveis

| Comportamento | Causa | Observação |
|---|---|---|
| O carrinho com empresas diferentes chega à finalização. | BUG-01 | É o que torna o BUG-03 observável. |
| Com carrinho misto, **Pagar** aparece, mas o pagamento é recusado. | BUG-03 | A rota de pagamento mantém a validação de empresas diferentes. |
| A interface continua funcionando com o campo a mais na listagem. | BUG-04 | O defeito só é detectado pela validação de contrato. |
| Um item pode ultrapassar a quantidade 99 após alteração. | BUG-02 | Viola a RN-10. O valor informado é aceito até 99 e dobra ao ser gravado. |

## 11. Matriz sugerida de validação

| Cenário | Referência | Resultado com os defeitos atuais |
|---|---|---|
| Login válido e inválido | US-02 | Passa |
| Navegação sem login | US-01 | Passa |
| Adição à mesma empresa | US-03 | Passa |
| Aviso ao trocar de empresa | RN-06 | Passa |
| Escolher **Não** no aviso | RN-08 | Passa |
| Escolher **Sim** no aviso | RN-07 | **Falha (BUG-01)** |
| Excluir item | CA-05.5 | Passa |
| Alterar quantidade | CA-05.2 | **Falha (BUG-02)** |
| Bloqueio por empresas diferentes | CA-06.2 | **Falha (BUG-03)** |
| Finalização e pagamento | US-06 / US-07 | Passa |
| Contrato da listagem de empresas | `GET /companies` | **Falha (BUG-04)** |
| Contrato dos demais endpoints | Seção 9 | Passa |

## 12. Requisitos não funcionais

- Execução local, com Node.js 22 ou superior e sem dependências externas.
- Servidor em `127.0.0.1`, porta `3000` por padrão (variáveis `HOST` e `PORT`).
- Caminho do banco configurável pela variável `DB_PATH`, para isolar execuções de teste.
- Interface responsiva, com rótulos acessíveis e localizadores estáveis para automação.
