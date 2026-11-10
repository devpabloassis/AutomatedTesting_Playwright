# Automação de Testes com Playwright

Projeto de estudo de automação de testes de **API** e **Web** com [Playwright](https://playwright.dev) e **BDD** (Gherkin em português).

O repositório tem duas partes:

- **`application/`**: um marketplace de comida, que é o sistema testado. Tem API e interface Web, e contém **defeitos inseridos de propósito** para que os testes falhem em pontos conhecidos.
- **`automated_testing/`**: o projeto de testes automatizados, com 385 testes de API, Web, contrato, caracteres de domínio e SQL injection.

## O sistema testado

Marketplace com 4 empresas (pizzaria, hamburgueria, comida japonesa e sucos), cada uma com 4 produtos.

- Navegar pelo catálogo sem login.
- Fazer login e montar um carrinho.
- O carrinho aceita itens de uma única empresa. Ao escolher um produto de outra empresa, aparece um aviso perguntando se o carrinho deve ser limpo.
- Alterar a quantidade e excluir itens.
- Finalizar o pedido e fazer um pagamento fake.

Tecnologia: Node.js 22, sem dependências externas. Os dados ficam em um arquivo JSON.

Usuários pré-cadastrados: `user_manual`, `user_robot`, `user_hybrid` e `user_fail`, todos com a senha `loveMetalSongs@`.

### Defeitos intencionais

Estes defeitos **não devem ser corrigidos**. Eles existem para mostrar como os testes detectam problemas. No código, estão marcados com o comentário `DEFEITO INTENCIONAL`.

| Defeito | Comportamento |
|---|---|
| BUG-01 | Ao confirmar a troca de empresa, o carrinho não é limpo |
| BUG-02 | Ao alterar a quantidade de um item, o valor é gravado em dobro |
| BUG-03 | O pedido com itens de empresas diferentes é concluído |
| BUG-04 | A listagem de empresas traz um campo que não está no contrato da API |

## Estrutura

```text
AutomatedTesting_Playwright/
├── application/                 # Sistema testado
│   ├── src/                     # API (server.js), catálogo e armazenamento
│   └── public/                  # Interface Web
├── automated_testing/           # Projeto de testes
│   ├── features/
│   │   ├── api/                 # Cenários de API em Gherkin
│   │   └── web/                 # Cenários Web em Gherkin
│   ├── steps/                   # Implementação dos passos do Gherkin
│   ├── support/                 # Fixtures, cliente da API, Page Objects e mapa de objetos
│   ├── contracts/               # JSON Schemas para os testes de contrato
│   └── playwright.config.ts
└── docs/                        # Documentação
```

## Como executar

Pré-requisito: Node.js 22 ou superior.

### Usar o sistema manualmente

```bash
cd application
npm start
```

Acesse `http://127.0.0.1:3000`.

### Executar os testes

```bash
cd automated_testing
npm install
npx playwright install chromium
npm test
```

Não é preciso subir o sistema antes: o Playwright inicia a aplicação na porta `3100`, com um banco limpo, e a encerra no final.

| Comando | O que executa |
|---|---|
| `npm test` | Todos os testes |
| `npm run test:api` | Somente API |
| `npm run test:web` | Somente Web |
| `npm run test:smoke` | Testes de fumaça |
| `npm run test:contract` | Testes de contrato |
| `npm run test:sem-bugs` | Tudo, exceto os cenários dos defeitos intencionais |
| `npm run test:bugs` | Somente os cenários dos defeitos intencionais |
| `npm run report` | Abre o relatório HTML da última execução |

### Resultado esperado

```text
  15 failed
  370 passed
```

As **15 falhas são esperadas**: cada uma corresponde a um dos defeitos intencionais. O motivo de cada falha está explicado no [guia de execução](docs/execucao_testes.md#52-falhas-previstas). Para uma execução sem falhas, use `npm run test:sem-bugs`.

## Exemplo de cenário

```gherkin
# language: pt
Funcionalidade: Troca de empresa

  @smoke @known_bug
  Cenário: CT-WEB-TRO-006 - Contador após Sim
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/empresas/hamburgueria"
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Sim"
    Então o contador do carrinho deve mostrar "1"
```

Cada cenário cria o próprio usuário pela API. Por isso os testes rodam em paralelo sem interferir uns nos outros.

## Documentação

| Documento | Conteúdo |
|---|---|
| [`docs/HISTORIA_DO_PRODUTO.md`](docs/HISTORIA_DO_PRODUTO.md) | Regras de negócio, histórias de usuário, critérios de aceite e defeitos intencionais |
| [`docs/API_ENDPOINTS.md`](docs/API_ENDPOINTS.md) | Os 11 endpoints da API, com exemplos, erros e contratos |
| [`docs/REPOSITORIO_TESTES_API.md`](docs/REPOSITORIO_TESTES_API.md) | Catálogo dos cenários de teste de API |
| [`docs/REPOSITORIO_TESTES_WEB.md`](docs/REPOSITORIO_TESTES_WEB.md) | Catálogo dos cenários de teste Web |
| [`docs/execucao_testes.md`](docs/execucao_testes.md) | Como executar, filtrar por tags e validar o resultado, e o motivo de cada falha prevista |

## Tecnologias

- [Playwright](https://playwright.dev) 1.65 com TypeScript
- [playwright-bdd](https://vitalets.github.io/playwright-bdd) para os cenários em Gherkin
- [Ajv](https://ajv.js.org) para validação de JSON Schema nos testes de contrato
- Node.js 22 no sistema testado, sem dependências externas
