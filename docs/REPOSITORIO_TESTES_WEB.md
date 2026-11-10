# Repositório de Testes — Web

> **Aviso:** este arquivo só existe porque nenhum repositório ou ferramenta de gestão de testes está integrado a este projeto. Ele é uma forma de **simular** que o repositório de testes existe em algum lugar.

| Campo | Valor |
|---|---|
| Sistema | Marketplace de Comida |
| Base | [`HISTORIA_DO_PRODUTO.md`](./HISTORIA_DO_PRODUTO.md) v1.0 |
| URL | `http://127.0.0.1:3000` |
| Repositório relacionado | [`REPOSITORIO_TESTES_API.md`](./REPOSITORIO_TESTES_API.md) |

## 1. Convenções

- **Tipo:** `P` fluxo principal, `A` fluxo alternativo, `E` fluxo de exceção.
- **Resultado esperado:** sempre descreve o comportamento correto. Quando um defeito intencional impede esse resultado, a linha traz **Falha prevista** e o valor obtido.
- **Tags:** todo cenário pertence também a `@web` e `@regression`. A coluna mostra as demais.
- **Massa:** cenários com carrinho devem criar um usuário próprio pela API e iniciar com sessão desse usuário, para poderem rodar em paralelo.
- **Preparação pela API:** quando a pré-condição não faz parte do que está sendo validado, ela deve ser montada pela API.

## 2. Navegação e catálogo (RN-01, US-01)

| ID | Cenário | Tipo | Pré-condição | Passos | Resultado esperado | Tags |
|---|---|---|---|---|---|---|
| CT-WEB-NAV-001 | Ver empresas sem login | P | Sem sessão | Abrir `/` | 4 empresas exibidas, link **Entrar** visível e contador 0 | `@smoke @feature_catalogo` |
| CT-WEB-NAV-002 | Abrir cada empresa | P | Sem sessão | Clicar em cada empresa | URL `/empresas/<id>` e 4 produtos exibidos | `@smoke @feature_catalogo` |
| CT-WEB-NAV-003 | Voltar pelo cabeçalho | A | Em uma empresa | Clicar em **Marketplace de Comida** | Lista de empresas exibida | `@feature_catalogo` |
| CT-WEB-NAV-004 | Voltar pelo navegador | A | Em uma empresa, vindo de `/` | Usar o botão voltar | Lista de empresas exibida | `@feature_catalogo` |
| CT-WEB-NAV-005 | Abrir empresa por URL direta | A | Sem sessão | Abrir `/empresas/sucos` | **Sucos da Fruta** com 4 produtos | `@feature_catalogo` |
| CT-WEB-NAV-006 | Empresa inexistente | E | — | Abrir `/empresas/inexistente` | `Empresa não encontrada` e link para voltar | `@feature_catalogo` |
| CT-WEB-NAV-007 | Rota inexistente | E | — | Abrir `/nao-existe` | `Página não encontrada` e link para voltar | `@feature_catalogo` |
| CT-WEB-NAV-008 | Falha ao carregar o catálogo | E | API de empresas respondendo 500 (simulada) | Abrir `/` | Mensagem de erro retornada pela API | `@feature_catalogo` |
| CT-WEB-NAV-009 | Layout em celular | A | Tela de 360 px | Abrir `/` | Empresas visíveis, sem rolagem horizontal | `@responsive` |

## 3. Produtos (US-01)

| ID | Cenário | Tipo | Pré-condição | Passos | Resultado esperado | Tags |
|---|---|---|---|---|---|---|
| CT-WEB-PRO-001 | Preço padrão com tamanho | P | Em `/empresas/pizzaria` | Observar **Portuguesa** | Tamanho **Pequeno** e `R$ 38,90` | `@smoke @feature_catalogo` |
| CT-WEB-PRO-002 | Trocar tamanho da pizza | P | Em `/empresas/pizzaria` | Selecionar **Médio** e depois **Grande** em **Portuguesa** | `R$ 52,90` e depois `R$ 66,90` | `@feature_catalogo` |
| CT-WEB-PRO-003 | Trocar tamanho do suco | A | Em `/empresas/sucos` | Selecionar **Grande** em **Laranja** | `R$ 14,90` | `@feature_catalogo` |
| CT-WEB-PRO-004 | Hambúrguer sem tamanho | A | Em `/empresas/hamburgueria` | Observar **Duplo** | `R$ 36,90`, sem seletor de tamanho | `@feature_catalogo` |
| CT-WEB-PRO-005 | Comida japonesa sem tamanho | A | Em `/empresas/japonesa` | Observar **Hot Filadélfia** | `R$ 29,90`, sem seletor de tamanho | `@feature_catalogo` |

## 4. Login (RN-02, RN-03, US-02)

| ID | Cenário | Tipo | Pré-condição | Passos | Resultado esperado | Tags |
|---|---|---|---|---|---|---|
| CT-WEB-LOG-001 | Login válido | P | Sem sessão | Informar usuário e senha válidos e clicar em **Entrar** | Página inicial, usuário no cabeçalho e opção **Sair** | `@smoke @feature_login` |
| CT-WEB-LOG-002 | Login dos pré-cadastrados | P | Sem sessão | Entrar com cada um dos 4 usuários | Login concedido a todos | `@feature_login` |
| CT-WEB-LOG-003 | Sessão mantida | A | Logado | Recarregar a página | Usuário continua no cabeçalho | `@feature_login` |
| CT-WEB-LOG-004 | Retorno à empresa | A | Sem sessão, em `/empresas/pizzaria` | Clicar em **Adicionar ao carrinho**; entrar | Volta a `/empresas/pizzaria` e o carrinho continua vazio | `@smoke @feature_login` |
| CT-WEB-LOG-005 | Retorno ao carrinho | A | Sem sessão, em `/carrinho` | Clicar em **Entrar**; informar credenciais | Volta a `/carrinho` | `@feature_login` |
| CT-WEB-LOG-006 | Sair | P | Logado | Clicar em **Sair** | Página inicial, link **Entrar** e contador 0 | `@smoke @feature_login` |
| CT-WEB-LOG-007 | Abrir login já logado | A | Logado | Abrir `/login` | Redirecionado à página inicial | `@feature_login` |
| CT-WEB-LOG-008 | Senha incorreta | E | Sem sessão | Informar senha errada | `Usuário ou senha inválidos.`, sem sessão | `@smoke @feature_login` |
| CT-WEB-LOG-009 | Usuário inexistente | E | Sem sessão | Informar usuário não cadastrado | `Usuário ou senha inválidos.`, sem sessão | `@feature_login` |
| CT-WEB-LOG-010 | Campos vazios | E | Sem sessão | Clicar em **Entrar** sem preencher | Permanece no login, sem chamada à API | `@feature_login` |
| CT-WEB-LOG-011 | Retorno externo bloqueado | E | Sem sessão | Abrir `/login?next=//exemplo.com`; entrar | Permanece no sistema, na página inicial | `@feature_login @security` |

## 5. Adicionar ao carrinho (RN-02, RN-09, RN-10, US-03)

| ID | Cenário | Tipo | Pré-condição | Passos | Resultado esperado | Tags |
|---|---|---|---|---|---|---|
| CT-WEB-ADD-001 | Adicionar em carrinho vazio | P | Logado, carrinho vazio | Adicionar **Portuguesa** **Médio** | `Produto adicionado ao carrinho.`, contador 1 e item com quantidade 1 | `@smoke @feature_carrinho` |
| CT-WEB-ADD-002 | Mesma empresa, outro produto | A | Item de `pizzaria` | Adicionar **Calabresa** | Sem aviso, contador 2 e 2 itens | `@feature_carrinho` |
| CT-WEB-ADD-003 | Mesmo produto e tamanho | A | Logado | Adicionar **Duplo** duas vezes | 1 item com quantidade 2 e contador 2 | `@feature_carrinho` |
| CT-WEB-ADD-004 | Mesmo produto, outro tamanho | A | Logado | Adicionar **Laranja** **Pequeno** e **Grande** | 2 itens e contador 2 | `@feature_carrinho` |
| CT-WEB-ADD-005 | Adicionar sem login | E | Sem sessão | Clicar em **Adicionar ao carrinho** | Tela de login com `Entre na sua conta para adicionar produtos ao carrinho.` | `@smoke @feature_carrinho` |
| CT-WEB-ADD-006 | Limite de quantidade | E | Item **Duplo** com quantidade 99, via API | Adicionar **Duplo** | `A quantidade do item não pode passar de 99.` e quantidade 99 mantida | `@feature_carrinho` |
| CT-WEB-ADD-007 | Falha da API ao adicionar | E | Inclusão respondendo 500 (simulada) | Adicionar um produto | Mensagem de erro retornada e contador inalterado | `@feature_carrinho` |
| CT-WEB-ADD-008 | Sessão de usuário inexistente | E | `marketplace.user` com usuário não cadastrado no localStorage | Adicionar um produto | `Usuário não encontrado.` | `@feature_carrinho` |

## 6. Troca de empresa (RN-05 a RN-08, US-04)

| ID | Cenário | Tipo | Pré-condição | Passos | Resultado esperado | Tags |
|---|---|---|---|---|---|---|
| CT-WEB-TRO-001 | Exibir aviso | P | Item de `pizzaria` | Adicionar produto de `hamburgueria` | Aviso de que o carrinho será limpo, com **Sim** e **Não** | `@smoke @feature_troca_empresa` |
| CT-WEB-TRO-002 | Confirmar com Sim limpa o carrinho | P | Item de `pizzaria` | Adicionar **Duplo**; clicar em **Sim**; abrir `/carrinho` | Carrinho somente com **Duplo**, na API e na página do carrinho. **Falha prevista (BUG-01):** o carrinho mantém **Portuguesa** e recebe **Duplo** | `@smoke @feature_troca_empresa @known_bug` |
| CT-WEB-TRO-003 | Recusar com Não | A | Item de `pizzaria` | Adicionar **Duplo**; clicar em **Não** | Aviso fechado, carrinho e contador inalterados | `@smoke @feature_troca_empresa` |
| CT-WEB-TRO-004 | Fechar aviso com Esc | A | Item de `pizzaria` | Adicionar **Duplo**; pressionar Esc | Mesmo efeito de **Não** | `@feature_troca_empresa` |
| CT-WEB-TRO-005 | Esc depois de um Sim anterior | E | Já houve um **Sim** na sessão | Provocar novo aviso; pressionar Esc | O produto não é adicionado | `@feature_troca_empresa` |
| CT-WEB-TRO-006 | Contador após Sim | P | 1 unidade de `pizzaria`; contador 1 | Adicionar **Duplo**; clicar em **Sim** | Contador 1. **Falha prevista (BUG-01):** contador 2 | `@smoke @feature_troca_empresa @known_bug` |
| CT-WEB-TRO-007 | Contador após Sim com várias unidades | A | 3 unidades de `pizzaria`; contador 3 | Adicionar **Duplo**; clicar em **Sim** | Contador 1. **Falha prevista (BUG-01):** contador 4 | `@feature_troca_empresa @known_bug` |
| CT-WEB-TRO-008 | Contador após Sim e recarregar a página | A | 1 unidade de `pizzaria` | Adicionar **Duplo**; clicar em **Sim**; recarregar; abrir `/carrinho` | Contador 1 após recarregar e na página do carrinho. **Falha prevista (BUG-01):** contador 2 | `@feature_troca_empresa @known_bug` |
| CT-WEB-TRO-009 | Contador após Sim e nova adição da mesma empresa | A | 1 unidade de `pizzaria` | Adicionar **Duplo**; clicar em **Sim**; adicionar **Completo** | Sem novo aviso e contador 2. **Falha prevista (BUG-01):** o aviso aparece de novo, pois **Portuguesa** continua no carrinho | `@feature_troca_empresa @known_bug` |
| CT-WEB-TRO-010 | Contador coerente com o carrinho após Sim | A | 1 unidade de `pizzaria` | Adicionar **Duplo**; clicar em **Sim**; abrir `/carrinho` | Contador igual à soma das quantidades do carrinho na API, antes e depois de abrir `/carrinho` | `@feature_troca_empresa` |
| CT-WEB-TRO-011 | Contador após Não com várias unidades | A | 3 unidades de `pizzaria`; contador 3 | Adicionar **Duplo**; clicar em **Não** | Aviso fechado e contador 3 | `@feature_troca_empresa` |

O cenário `CT-WEB-TRO-010` mostra que o contador é atualizado e acompanha o carrinho real. Os cenários `CT-WEB-TRO-006` a `009` falham porque o carrinho real não é limpo.

## 7. Carrinho (RN-04, RN-10 a RN-13, US-05)

| ID | Cenário | Tipo | Pré-condição | Passos | Resultado esperado | Tags |
|---|---|---|---|---|---|---|
| CT-WEB-CAR-001 | Exibir dados do item | P | 1 **Portuguesa** **Médio** | Abrir `/carrinho` | Produto, empresa, opção, unitário `R$ 52,90`, quantidade 1, subtotal e total `R$ 52,90` | `@smoke @feature_carrinho` |
| CT-WEB-CAR-002 | Carrinho vazio | A | Logado, sem itens | Abrir `/carrinho` | `Seu carrinho está vazio.` e link **Ver empresas** | `@feature_carrinho` |
| CT-WEB-CAR-003 | Carrinho sem login | E | Sem sessão | Abrir `/carrinho` | `Entre na sua conta para ver o carrinho.` e botão **Entrar** | `@feature_carrinho` |
| CT-WEB-CAR-004 | Alterar quantidade | P | 1 item | Informar 3; clicar em **Atualizar** | Quantidade 3. **Falha prevista (BUG-02):** quantidade 6 | `@smoke @feature_carrinho @known_bug` |
| CT-WEB-CAR-005 | Recalcular valores | P | 1 **Portuguesa** **Médio** | Informar 3; clicar em **Atualizar** | Subtotal e total `R$ 158,70`, contador 3. **Falha prevista (BUG-02):** `R$ 317,40` e contador 6 | `@feature_carrinho @known_bug` |
| CT-WEB-CAR-006 | Quantidade zero | E | 1 item | Informar 0; **Atualizar** | `A quantidade deve ser um número inteiro de 1 a 99.` e item inalterado | `@feature_carrinho` |
| CT-WEB-CAR-007 | Quantidade acima do máximo | E | 1 item | Informar 100; **Atualizar** | Mesma mensagem e item inalterado | `@feature_carrinho` |
| CT-WEB-CAR-008 | Quantidade negativa | E | 1 item | Informar -1; **Atualizar** | Mesma mensagem e item inalterado | `@feature_carrinho` |
| CT-WEB-CAR-009 | Quantidade decimal | E | 1 item | Informar 1,5; **Atualizar** | Mesma mensagem e item inalterado | `@feature_carrinho` |
| CT-WEB-CAR-010 | Quantidade vazia | E | 1 item | Limpar o campo; **Atualizar** | Mesma mensagem e item inalterado | `@feature_carrinho` |
| CT-WEB-CAR-011 | Excluir um de vários itens | P | 2 itens da mesma empresa | **Excluir** um item | Item removido, total e contador recalculados | `@smoke @feature_carrinho` |
| CT-WEB-CAR-012 | Excluir o último item | A | 1 item | **Excluir** | `Seu carrinho está vazio.` e contador 0 | `@feature_carrinho` |
| CT-WEB-CAR-013 | Carrinhos independentes | A | Usuário A com item; usuário B sem itens | Entrar com B; abrir `/carrinho` | Carrinho de B vazio | `@feature_carrinho` |
| CT-WEB-CAR-014 | Carrinho mantido | A | 1 item | Recarregar; sair e entrar novamente | Item permanece no carrinho | `@feature_carrinho` |

## 8. Finalização (RN-14 a RN-16, US-06)

| ID | Cenário | Tipo | Pré-condição | Passos | Resultado esperado | Tags |
|---|---|---|---|---|---|---|
| CT-WEB-FIN-001 | Finalizar carrinho válido | P | Itens de uma empresa | Clicar em **Finalizar pedido** | `Pedido Concluído` e botão **Pagar** | `@smoke @feature_pedido` |
| CT-WEB-FIN-002 | Empresas diferentes | E | Carrinho misto, gerado pelo BUG-01 | Clicar em **Finalizar pedido** | `Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido.`, retornada pelo backend, sem **Pagar**. **Falha prevista (BUG-03):** `Pedido Concluído` e botão **Pagar** exibidos | `@smoke @feature_pedido @known_bug` |
| CT-WEB-FIN-003 | Alterar após finalizar | A | Botão **Pagar** visível | Alterar quantidade | Botão **Pagar** deixa de ser exibido | `@feature_pedido` |
| CT-WEB-FIN-004 | Excluir após finalizar | A | 2 itens e **Pagar** visível | Excluir um item | Botão **Pagar** deixa de ser exibido | `@feature_pedido` |
| CT-WEB-FIN-005 | Recarregar após finalizar | A | Botão **Pagar** visível | Recarregar | É necessário finalizar novamente; **Pagar** não aparece | `@feature_pedido` |
| CT-WEB-FIN-006 | Pagar antes de finalizar | E | Carrinho com itens | Abrir `/carrinho` | Botão **Pagar** não é exibido | `@feature_pedido` |
| CT-WEB-FIN-007 | Carrinho vazio | E | Sem itens | Abrir `/carrinho` | **Finalizar pedido** e **Pagar** não são exibidos | `@feature_pedido` |
| CT-WEB-FIN-008 | Carrinho esvaziado em outra sessão | E | Tela do carrinho aberta; itens removidos via API | Clicar em **Finalizar pedido** | `O carrinho está vazio.`, sem **Pagar** | `@feature_pedido` |

O cenário `CT-WEB-FIN-002` depende do BUG-01 para montar a pré-condição. Quando esse defeito for corrigido, ele deixará de ser alcançável pela interface.

## 9. Pagamento (RN-17, US-07)

| ID | Cenário | Tipo | Pré-condição | Passos | Resultado esperado | Tags |
|---|---|---|---|---|---|---|
| CT-WEB-PAG-001 | Pagar pedido | P | Botão **Pagar** visível | Clicar em **Pagar** | `Pagamento Fake efetuado` | `@smoke @feature_pagamento` |
| CT-WEB-PAG-002 | Carrinho após pagamento | P | Pagamento concluído | Observar a tela | `Seu carrinho está vazio.` e contador 0 | `@smoke @feature_pagamento` |
| CT-WEB-PAG-003 | Carrinho esvaziado antes de pagar | E | **Pagar** visível; itens removidos via API | Clicar em **Pagar** | `O carrinho está vazio.` e botão **Pagar** removido | `@feature_pagamento` |
| CT-WEB-PAG-004 | Falha da API ao pagar | E | Pagamento respondendo 500 (simulado) | Clicar em **Pagar** | Mensagem de erro retornada, sem `Pagamento Fake efetuado` | `@feature_pagamento` |
| CT-WEB-PAG-005 | Pagar com empresas diferentes | E | **Pagar** visível; carrinho misto, gerado pelo BUG-01 | Clicar em **Pagar** | `Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido.`, sem `Pagamento Fake efetuado`, itens mantidos e botão **Pagar** removido | `@feature_pagamento` |

O cenário `CT-WEB-PAG-005` também depende do BUG-01 para montar a pré-condição.

## 10. Execução por tags

| Objetivo | Comando previsto |
|---|---|
| Fumaça Web | `npx playwright test --project=web-chromium --grep @smoke` |
| Login | `npx playwright test --project=web-chromium --grep @feature_login` |
| Carrinho | `npx playwright test --project=web-chromium --grep @feature_carrinho` |
| Troca de empresa | `npx playwright test --project=web-chromium --grep @feature_troca_empresa` |
| Sem defeitos conhecidos | `npx playwright test --project=web-chromium --grep-invert @known_bug` |
