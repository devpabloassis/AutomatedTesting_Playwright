# language: pt
@web @regression @feature_pedido
Funcionalidade: Finalização do pedido
  Como cliente
  Quero finalizar o carrinho
  Para seguir ao pagamento

  Contexto:
    Dado que estou logado com um usuário novo

  @smoke
  Cenário: CT-WEB-FIN-001 - Finalizar carrinho válido
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/carrinho"
    Quando finalizo o pedido
    Então devo ver a mensagem "Pedido Concluído"
    E o botão Pagar deve estar visível

  # Falha prevista: BUG-03. A preparação depende do BUG-01.
  @smoke @known_bug
  Cenário: CT-WEB-FIN-002 - Empresas diferentes
    Dado que o carrinho do usuário tem itens de empresas diferentes
    E que estou na página "/carrinho"
    Quando finalizo o pedido
    Então devo ver a mensagem "Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido."
    E o botão Pagar não deve estar visível

  Cenário: CT-WEB-FIN-003 - Alterar após finalizar
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/carrinho"
    Quando finalizo o pedido
    Então o botão Pagar deve estar visível
    Quando altero a quantidade do item "portuguesa/M" para "2"
    Então o botão Pagar não deve estar visível

  Cenário: CT-WEB-FIN-004 - Excluir após finalizar
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que o carrinho do usuário tem o item "pizzaria/calabresa/P"
    E que estou na página "/carrinho"
    Quando finalizo o pedido
    Então o botão Pagar deve estar visível
    Quando excluo o item "calabresa/P"
    Então o botão Pagar não deve estar visível

  Cenário: CT-WEB-FIN-005 - Recarregar após finalizar
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/carrinho"
    Quando finalizo o pedido
    Então o botão Pagar deve estar visível
    Quando recarrego a página
    Então o botão Finalizar pedido deve estar visível
    E o botão Pagar não deve estar visível

  Cenário: CT-WEB-FIN-006 - Pagar antes de finalizar
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando abro a página "/carrinho"
    Então o botão Finalizar pedido deve estar visível
    E o botão Pagar não deve estar visível

  Cenário: CT-WEB-FIN-007 - Carrinho vazio
    Quando abro a página "/carrinho"
    Então devo ver o aviso de carrinho vazio
    E o botão Finalizar pedido não deve estar visível
    E o botão Pagar não deve estar visível

  Cenário: CT-WEB-FIN-008 - Carrinho esvaziado em outra sessão
    Dado que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/carrinho"
    E o botão Finalizar pedido deve estar visível
    Quando o carrinho é esvaziado em outra sessão
    E finalizo o pedido
    Então devo ver a mensagem "O carrinho está vazio."
    E o botão Pagar não deve estar visível
