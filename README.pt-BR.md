# Automação de Testes com Playwright

[![Tests](https://github.com/devpabloassis/AutomatedTesting_Playwright/actions/workflows/tests.yml/badge.svg)](https://github.com/devpabloassis/AutomatedTesting_Playwright/actions/workflows/tests.yml)

[English](README.md) | **Português (Brasil)**

Projeto de automação de testes de **API** e **Web** com [Playwright](https://playwright.dev), TypeScript e **BDD** (Gherkin).

> O código, os cenários Gherkin e a documentação técnica estão em inglês, seguindo o padrão de projetos profissionais. Este arquivo é um resumo em português.

O repositório tem duas partes:

- **`application/`**: um marketplace de comida, que é o sistema testado. Tem API e interface Web, e contém **defeitos inseridos de propósito** para que os testes falhem em pontos conhecidos.
- **`automated_testing/`**: o projeto de testes automatizados, com 385 testes de API, Web, contrato, caracteres de domínio e SQL injection.

## Destaques

- **BDD com Gherkin** via [playwright-bdd](https://vitalets.github.io/playwright-bdd): cada cenário é rastreável até um caso de teste documentado (`TC-API-*`, `TC-WEB-*`).
- **Page Object Model** e um **mapa de objetos** central, com seletores estáveis por `id`.
- **Testes de contrato** com JSON Schema e [Ajv](https://ajv.js.org), com mensagens de violação legíveis.
- **Testes orientados a dados** com `Scenario Outline` (domínio de campos e payloads de SQL injection).
- **Paralelos e isolados:** cada cenário cria o próprio usuário pela API; os cenários de persistência sobem servidor e banco próprios.
- **Defeitos conhecidos marcados com tag** (`@known_bug`), separando regressões reais de falhas esperadas.
- **Integração contínua** com GitHub Actions: typecheck, a suíte sem os defeitos conhecidos como critério de aprovação e a verificação de que os 15 defeitos conhecidos continuam falhando.
- Relatórios HTML e JUnit, com trace e screenshot nas falhas.

## O sistema testado

Marketplace com 4 empresas (pizzaria, hamburgueria, comida japonesa e sucos), cada uma com 4 produtos. É possível navegar sem login, montar um carrinho de uma única empresa (com aviso ao trocar de empresa), alterar e excluir itens, finalizar o pedido e fazer um pagamento fake.

Usuários pré-cadastrados: `user_manual`, `user_robot`, `user_hybrid` e `user_fail`, todos com a senha `loveMetalSongs@`.

### Defeitos intencionais

Estes defeitos **não devem ser corrigidos**. No código, estão marcados com o comentário `INTENTIONAL DEFECT`.

| Defeito | Comportamento |
|---|---|
| BUG-01 | Ao confirmar a troca de empresa, o carrinho não é limpo |
| BUG-02 | Ao alterar a quantidade de um item, o valor é gravado em dobro |
| BUG-03 | O pedido com itens de empresas diferentes é concluído |
| BUG-04 | A listagem de empresas traz um campo que não está no contrato da API |

## Como executar

Pré-requisito: Node.js 22 ou superior.

```bash
# Usar o sistema manualmente (http://127.0.0.1:3000)
cd application
npm start

# Executar os testes
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
| `npm run test:no-bugs` | Tudo, exceto os cenários dos defeitos intencionais |
| `npm run test:known-bugs` | Somente os cenários dos defeitos intencionais |
| `npm run report` | Abre o relatório HTML da última execução |

### Resultado esperado

```text
  15 failed
  370 passed
```

As **15 falhas são esperadas**: cada uma corresponde a um dos defeitos intencionais. O motivo de cada falha está no [guia de execução](docs/TEST_EXECUTION.md#52-expected-failures) (em inglês). Para uma execução sem falhas, use `npm run test:no-bugs`.

## Documentação

A documentação completa está em inglês, na pasta [`docs/`](docs/):

| Documento | Conteúdo |
|---|---|
| [`PRODUCT_SPEC.md`](docs/PRODUCT_SPEC.md) | Regras de negócio, histórias de usuário, critérios de aceite e defeitos intencionais |
| [`API_ENDPOINTS.md`](docs/API_ENDPOINTS.md) | Os 11 endpoints da API, com exemplos, erros e contratos |
| [`API_TEST_CASES.md`](docs/API_TEST_CASES.md) | Catálogo dos casos de teste de API |
| [`WEB_TEST_CASES.md`](docs/WEB_TEST_CASES.md) | Catálogo dos casos de teste Web |
| [`TEST_EXECUTION.md`](docs/TEST_EXECUTION.md) | Como executar, filtrar por tags e validar o resultado |

## Tecnologias

- [Playwright](https://playwright.dev) 1.65 com TypeScript
- [playwright-bdd](https://vitalets.github.io/playwright-bdd) para os cenários em Gherkin
- [Ajv](https://ajv.js.org) para validação de JSON Schema
- Node.js 22 no sistema testado, sem dependências externas
