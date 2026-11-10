# Execução dos Testes

Este documento explica como executar os testes automatizados do Marketplace de Comida e como validar o resultado.

## 1. Estrutura do projeto

```text
AutomatedTesting_Playwright/
├── docs/                           # História do produto, API, repositórios de testes e este guia
├── application/                     # Sistema: API, HTML e dados
│   ├── src/
│   ├── public/
│   └── data/db.json                # Banco de uso manual (gerado)
└── automated_testing/              # Projeto Playwright com BDD
    ├── playwright.config.ts
    ├── package.json
    ├── features/
    │   ├── api/                    # Cenários de API em Gherkin (.feature)
    │   └── web/                    # Cenários Web em Gherkin (.feature)
    ├── steps/                      # Passos: ligam as frases do Gherkin ao código
    │   ├── common.steps.ts         # Usuário e carrinho (API e Web)
    │   ├── api.steps.ts
    │   └── web.steps.ts
    ├── support/                    # Fixtures, cliente da API, massa, Page Objects,
    │                               # mapa de objetos (object-map.ts) e validador de contrato
    ├── contracts/                  # JSON Schemas das respostas da API (contrato)
    └── .features-gen/              # Testes gerados a partir das features (não editar)
```

## 1.1 Como os cenários BDD funcionam

Os cenários estão escritos em Gherkin, em português, com a biblioteca **playwright-bdd**:

1. Cada `.feature` descreve os cenários com `Dado`, `Quando` e `Então`, usando os mesmos IDs e tags dos repositórios de testes.
2. Cada frase corresponde a um passo em `steps/`, que usa os Page Objects, o mapa de objetos e o cliente da API.
3. O comando `bddgen` converte as features em testes do Playwright, na pasta `.features-gen/`. Os scripts `npm run ...` já executam esse comando antes dos testes.

Exemplo:

```gherkin
@smoke @known_bug
Cenário: CT-WEB-TRO-006 - Contador após Sim
  Quando adiciono o produto "duplo" ao carrinho
  E confirmo a troca de empresa com "Sim"
  Então devo ver a mensagem "Produto adicionado ao carrinho."
  E o contador do carrinho deve mostrar "1"
```

Os cenários orientados a dados usam `Esquema do Cenário` com uma tabela de `Exemplos`, onde cada linha vira um teste.

Nas requisições de API, marcadores entre chaves são trocados por valores do cenário. Exemplos: `{usuario}` é o usuário criado, `{item}` é o item do carrinho, `{nome_unico}` gera um nome novo e `{payload}` é o payload de SQL injection.

## 1.2 Testes de contrato

Os testes de contrato (`features/api/contrato.feature`, tag `@contract`) verificam a **estrutura** de cada resposta, não os valores:

- Cada resposta é comparada com um JSON Schema de `automated_testing/contracts/`, usando a biblioteca `ajv`.
- O contrato exige os campos obrigatórios com o tipo e o formato certos e **recusa campos a mais**.
- Há cenários de sucesso e de erro para os 11 endpoints, documentados em [`API_ENDPOINTS.md`](./API_ENDPOINTS.md).

```gherkin
Cenário: CT-API-CON-008 - Listar empresas
  Quando envio "GET" para "/companies"
  Então o status da resposta deve ser 200
  E a resposta deve seguir o contrato "companies"
```

Quando a resposta não segue o contrato, o erro lista cada violação:

```text
- Array []
+ Array [
+   "[0].commissionPercent: campo não previsto no contrato",
+   ...
+ ]
```

## 2. Pré-requisitos

- Node.js 22 ou superior.
- Na primeira execução, instale as dependências:

```bash
cd automated_testing
npm install
npx playwright install chromium
```

Todos os comandos seguintes devem ser executados dentro de `automated_testing/`.

## 3. Como o ambiente de teste funciona

**Não é preciso subir a aplicação antes dos testes.** O Playwright inicia o sistema automaticamente na porta `3100` e o encerra ao final.

- Cada execução começa com um banco limpo em `automated_testing/.test-data/db.json`. O banco manual, `application/data/db.json`, não é alterado.
- Os testes criam usuários próprios pela API, por isso rodam em paralelo sem interferir uns nos outros.
- Os cenários de persistência (`CT-API-GER-010` a `012`) sobem servidores próprios a partir da porta `3200`, pois precisam reiniciar o sistema.
- Não há retentativas automáticas, para que os defeitos intencionais apareçam como falhas diretas.

Para usar outra porta caso a `3100` esteja ocupada:

```bash
TEST_PORT=3110 npm test
```

Para usar o sistema manualmente:

```bash
cd application
npm start
```

Depois, acesse `http://127.0.0.1:3000`.

## 4. Comandos de execução

| Objetivo | Comando | Testes | Aprovados | Reprovados |
|---|---|---:|---:|---:|
| Todos | `npm test` | 385 | 370 | 15 |
| Somente API | `npm run test:api` | 314 | 307 | 7 |
| Somente Web | `npm run test:web` | 71 | 63 | 8 |
| Fumaça | `npm run test:smoke` | 43 | 35 | 8 |
| Regressão | `npm run test:regression` | 385 | 370 | 15 |
| Login | `npm run test:login` | 37 | 37 | 0 |
| Carrinho | `npm run test:carrinho` | 73 | 66 | 7 |
| Caracteres de domínio | `npm run test:domain` | 57 | 57 | 0 |
| SQL injection | `npm run test:sqli` | 137 | 137 | 0 |
| Contrato | `npm run test:contract` | 28 | 27 | 1 |
| Sem defeitos conhecidos | `npm run test:sem-bugs` | 370 | 370 | 0 |
| Somente defeitos conhecidos | `npm run test:bugs` | 15 | 0 | 15 |

Os repositórios têm 266 IDs de cenário. O total é 385 porque 17 cenários de SQL injection rodam uma vez para cada um dos 8 payloads.

### Filtros personalizados

Ao usar `npx playwright` diretamente, execute antes `npx bddgen` sempre que alterar um `.feature` ou um passo.

```bash
# Uma tag
npx playwright test --grep @feature_pagamento

# Uma tag ou outra
npx playwright test --grep "@feature_login|@feature_pagamento"

# As duas tags ao mesmo tempo
npx playwright test --grep "(?=.*@smoke)(?=.*@feature_carrinho)"

# Tag em apenas um projeto
npx playwright test --project=web-chromium --grep @smoke

# Um cenário pelo ID
npx playwright test --grep CT-WEB-CAR-004

# Ver quais testes seriam executados, sem executar
npx playwright test --list --grep @smoke
```

As tags disponíveis são: `@api`, `@web`, `@regression`, `@smoke`, `@known_bug`, `@domain`, `@sqli`, `@contract`, `@security`, `@persistence`, `@responsive`, `@feature_usuario`, `@feature_login`, `@feature_catalogo`, `@feature_carrinho`, `@feature_troca_empresa`, `@feature_pedido` e `@feature_pagamento`.

### Modos de depuração

| Objetivo | Comando |
|---|---|
| Interface visual interativa | `npm run test:ui` |
| Ver o navegador durante o teste | `npx playwright test --project=web-chromium --headed` |
| Depurar passo a passo | `npx playwright test --grep CT-WEB-CAR-004 --debug` |

## 5. Como validar o resultado

### 5.1 Resultado esperado

`npm test` deve terminar com **370 aprovados e 15 reprovados**:

```text
  15 failed
    ...
  370 passed
```

Como existem reprovações, o comando termina com **código de saída 1**. Enquanto os defeitos intencionais existirem, esse é o resultado correto da suíte completa.

Para obter uma execução sem reprovações, use `npm run test:sem-bugs`, que deve terminar com código de saída 0.

### 5.2 Falhas previstas

Os 15 cenários abaixo validam o **comportamento correto** e falham porque o sistema tem 4 defeitos inseridos de propósito. Os defeitos estão descritos na seção 10 da [história do produto](./HISTORIA_DO_PRODUTO.md) e marcados no código com o comentário `DEFEITO INTENCIONAL`. Todos os 15 cenários têm a tag `@known_bug`.

Resumo:

| Defeito | Endpoint com o defeito | API | Web | Total |
|---|---|---:|---:|---:|
| BUG-01 — Carrinho não é limpo ao trocar de empresa | `POST /users/:username/cart/items` | 1 | 5 | 6 |
| BUG-02 — Quantidade duplicada ao alterar item | `PATCH /users/:username/cart/items/:itemId` | 4 | 2 | 6 |
| BUG-03 — Pedido com empresas diferentes é concluído | `POST /users/:username/cart/checkout` | 1 | 1 | 2 |
| BUG-04 — Listagem de empresas fora do contrato | `GET /companies` | 1 | 0 | 1 |
| **Total** | | **7** | **8** | **15** |

#### BUG-01 — Carrinho não é limpo ao trocar de empresa

**Por que falha:** ao confirmar a troca de empresa (`replaceCart: true`, ou **Sim** no aviso da tela), a API deveria esvaziar o carrinho antes de incluir o novo produto. A linha que faz isso não existe em `application/src/server.js` (`addCartItem`). O carrinho fica com o item antigo e o novo, de empresas diferentes. O contador do cabeçalho mostra `totalItems`, a soma das quantidades desse carrinho, por isso também fica errado.

| Cenário | Tipo | O que valida | Esperado | Obtido | Passo que falha |
|---|---|---|---|---|---|
| `CT-API-CAR-020` | API | Adicionar item de outra empresa com `replaceCart: true` | Itens: `duplo` | Itens: `portuguesa`, `duplo` | `E o carrinho retornado deve conter somente os produtos "duplo"` |
| `CT-WEB-TRO-002` | Web | Clicar em **Sim** limpa o carrinho | Itens: `duplo` | Itens: `portuguesa`, `duplo` | `E o carrinho do usuário deve conter somente os produtos "duplo"` |
| `CT-WEB-TRO-006` | Web | Contador após **Sim** | `1` | `2` | `E o contador do carrinho deve mostrar "1"` |
| `CT-WEB-TRO-007` | Web | Contador após **Sim**, com 3 unidades antes | `1` | `4` | `E o contador do carrinho deve mostrar "1"` |
| `CT-WEB-TRO-008` | Web | Contador após **Sim** e recarregar a página | `1` | `2` | `Então o contador do carrinho deve mostrar "1"` |
| `CT-WEB-TRO-009` | Web | Após **Sim**, adicionar outro produto da nova empresa | Sem novo aviso | Aviso exibido de novo, pois a pizza continua no carrinho | `Então o aviso de troca de empresa não deve estar visível` |

#### BUG-02 — Quantidade duplicada ao alterar item

**Por que falha:** ao alterar a quantidade, a API grava o dobro do valor informado (`item.quantity = body.quantity * 2`, em `updateCartItem`). Subtotal, total e contador são calculados a partir dessa quantidade errada.

| Cenário | Tipo | O que valida | Esperado | Obtido | Passo que falha |
|---|---|---|---|---|---|
| `CT-API-CAR-030` | API | Alterar a quantidade para 3 | Quantidade `3` | Quantidade `6` | `E a resposta deve conter:` |
| `CT-API-CAR-031` | API | Alterar para o limite mínimo (1) | Quantidade `1` | Quantidade `2` | `E a resposta deve conter:` |
| `CT-API-CAR-032` | API | Alterar para o limite máximo (99) | Quantidade `99` | Quantidade `198`, acima do limite da RN-10 | `E a resposta deve conter:` |
| `CT-API-CAR-033` | API | Recalcular subtotal e total | Subtotal `15870` | Subtotal `31740` | `E a resposta deve conter:` |
| `CT-WEB-CAR-004` | Web | Alterar a quantidade na tela | Campo com `3` | Campo com `6` | `E a quantidade do item "portuguesa/M" na tela deve ser "3"` |
| `CT-WEB-CAR-005` | Web | Valores recalculados na tela | Subtotal `R$ 158,70` | Subtotal `R$ 317,40` | `E o subtotal do item "portuguesa/M" deve ser "R$ 158,70"` |

#### BUG-03 — Pedido com empresas diferentes é concluído

**Por que falha:** ao finalizar, a API deveria recusar o carrinho com empresas diferentes (422 `CART_MIXED_COMPANIES`). A rota `checkout` valida só o carrinho vazio e retorna 200. A tela então mostra `Pedido Concluído` e o botão **Pagar**. A rota de pagamento não tem o defeito e recusa esse carrinho.

Esse carrinho misto só pode ser montado por causa do BUG-01. Por isso a preparação destes cenários depende dele.

| Cenário | Tipo | O que valida | Esperado | Obtido | Passo que falha |
|---|---|---|---|---|---|
| `CT-API-PED-003` | API | Finalizar carrinho com empresas diferentes | 422 `CART_MIXED_COMPANIES` | 200 `READY_FOR_PAYMENT` | `Então a resposta deve ser um erro 422 com o código "CART_MIXED_COMPANIES"` |
| `CT-WEB-FIN-002` | Web | Mensagem ao finalizar com empresas diferentes | `Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido.` | `Pedido Concluído` | `Então devo ver a mensagem "Existem itens de empresas diferentes..."` |

#### BUG-04 — Listagem de empresas fora do contrato

**Por que falha:** `GET /companies` acrescenta a cada empresa o campo interno `commissionPercent`, que não está no contrato `companies` (`automated_testing/contracts/`). O contrato não aceita campos a mais. A tela e os testes funcionais não percebem o campo extra: só a validação de contrato detecta o defeito. `GET /companies/:companyId` não tem o defeito, e por isso o `CT-API-CON-009` passa.

| Cenário | Tipo | O que valida | Esperado | Obtido | Passo que falha |
|---|---|---|---|---|---|
| `CT-API-CON-008` | API | Resposta de `GET /companies` segue o contrato | Nenhuma violação | `[0].commissionPercent: campo não previsto no contrato`, e o mesmo para `[1]`, `[2]` e `[3]` | `E a resposta deve seguir o contrato "companies"` |

#### Cenários que dependem de defeitos, mas passam

Estes cenários usam o BUG-01 apenas para montar um carrinho com empresas diferentes. O que eles validam funciona corretamente, por isso passam e **não** têm `@known_bug`:

| Cenário | O que valida |
|---|---|
| `CT-API-PED-013` | `POST /cart/pay` recusa carrinho misto com 422 `CART_MIXED_COMPANIES` |
| `CT-API-CON-025` | O erro 422 do pagamento com carrinho misto segue o contrato `error` |
| `CT-WEB-PAG-005` | A tela recusa o pagamento com carrinho misto e mantém os itens |
| `CT-WEB-TRO-010` | O contador acompanha o carrinho real após **Sim**. Ele confirma que o contador é atualizado e que o erro está no carrinho, não no contador |

#### Se um defeito for corrigido

| Defeito corrigido | Cenários que passam a passar | Efeito colateral |
|---|---|---|
| BUG-01 | Os 6 da tabela do BUG-01 | `CT-API-PED-003`, `CT-WEB-FIN-002`, `CT-API-PED-013`, `CT-API-CON-025` e `CT-WEB-PAG-005` não conseguem mais montar o carrinho misto e precisam de outra preparação |
| BUG-02 | Os 6 da tabela do BUG-02 | Nenhum |
| BUG-03 | `CT-API-PED-003` e `CT-WEB-FIN-002` | Nenhum |
| BUG-04 | `CT-API-CON-008` | Nenhum |

### 5.3 Roteiro de validação

1. Confira se o resumo mostra 370 aprovados e 15 reprovados.
2. Compare os IDs reprovados com a tabela da seção 5.2.
3. Confira, no relatório, se o valor esperado e o obtido de cada falha correspondem à tabela.
4. Execute `npm run test:sem-bugs` e confirme 370 aprovados.

| Situação | Interpretação |
|---|---|
| Somente os 15 cenários acima falharam, com os valores da tabela | Execução válida |
| Um cenário fora da tabela falhou | Possível regressão ou problema de ambiente: investigar |
| Um cenário da tabela passou | O defeito pode ter sido corrigido: confirmar no sistema |
| Um cenário da tabela falhou com outro valor ou erro | A falha tem outra causa: investigar |
| O total de testes é diferente de 385 | Filtro aplicado ou testes alterados: conferir o comando |

### 5.4 Relatórios gerados

| Relatório | Local | Uso |
|---|---|---|
| Console | Saída do terminal | Acompanhar a execução e ver o resumo |
| HTML | `automated_testing/playwright-report/` | Análise detalhada, com filtros por status e tag |
| JUnit | `automated_testing/test-results/junit.xml` | Integração com ferramentas de CI |
| Evidências | `automated_testing/test-results/` | Screenshots e traces dos testes reprovados |

Para abrir o relatório HTML:

```bash
npm run report
```

No relatório, é possível filtrar por **Failed** e abrir cada teste para ver o erro e as etapas. Em testes Web reprovados, há também screenshot e trace.

Para abrir um trace diretamente:

```bash
npx playwright show-trace test-results/<pasta-do-teste>/trace.zip
```

O Trace Viewer mostra cada ação com o estado da página, as requisições e o console. A pasta `test-results/` é limpa a cada execução, assim como o relatório é substituído.

## 6. Depois de corrigir um defeito

Os cenários da tabela 5.2 passarão a ser aprovados quando o defeito correspondente for corrigido em `application/src/server.js`. Nesse caso:

1. Remova a tag `@known_bug` dos cenários corrigidos e atualize a seção 10 da história do produto.
2. Com o **BUG-01** corrigido, `CT-API-PED-003`, `CT-API-PED-013`, `CT-WEB-FIN-002` e `CT-WEB-PAG-005` deixam de conseguir montar um carrinho com empresas diferentes. Eles precisarão de outra forma de preparação ou deverão ser retirados, mesmo com o **BUG-03** ainda presente.

## 7. Problemas comuns

| Sintoma | Solução |
|---|---|
| `Executable doesn't exist` | Execute `npx playwright install chromium` |
| `http://127.0.0.1:3100/... is already used` | Encerre o processo que usa a porta ou defina `TEST_PORT` |
| `Cannot find module '@playwright/test'` | Execute `npm install` dentro de `automated_testing/` |
| `No tests found` | Execute `npx bddgen`, confira se está em `automated_testing/` e se a tag existe |
| `Missing step definitions` | A frase do `.feature` não corresponde a nenhum passo. O `bddgen` mostra o código sugerido para criar o passo em `steps/` |
| Falha em `CT-API-GER-010` a `012` por servidor não iniciado | Libere as portas a partir de `3200` |
| Testes Web lentos ou com timeout | Reduza o paralelismo: `npx playwright test --workers=2` |
