# language: pt
@web @regression @feature_pagamento
Funcionalidade: Pagamento
  Como cliente
  Quero pagar o pedido finalizado
  Para concluir a compra

  Contexto:
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/carrinho"
    E finalizo o pedido
    E o botão Pagar deve estar visível

  @smoke
  Cenário: CT-WEB-PAG-001 - Pagar pedido
    Quando clico em Pagar
    Então devo ver a mensagem "Pagamento Fake efetuado"

  @smoke
  Cenário: CT-WEB-PAG-002 - Carrinho após pagamento
    Quando clico em Pagar
    Então devo ver o aviso de carrinho vazio
    E o contador do carrinho deve mostrar "0"

  Cenário: CT-WEB-PAG-003 - Carrinho esvaziado antes de pagar
    Quando o carrinho é esvaziado em outra sessão
    E clico em Pagar
    Então devo ver a mensagem "O carrinho está vazio."
    E o botão Pagar não deve estar visível

  Cenário: CT-WEB-PAG-004 - Falha da API ao pagar
    Dado que a API responde com erro 500 em "**/cart/pay"
    Quando clico em Pagar
    Então devo ver a mensagem "Erro interno."
    E a mensagem "Pagamento Fake efetuado" não deve aparecer

  # A preparação depende do BUG-01.
  Cenário: CT-WEB-PAG-005 - Pagar com empresas diferentes
    Quando o carrinho recebe em outra sessão o item "hamburgueria/duplo/U" com troca de empresa
    E clico em Pagar
    Então devo ver a mensagem "Existem itens de empresas diferentes no carrinho. Não é possível concluir o pedido."
    E a mensagem "Pagamento Fake efetuado" não deve aparecer
    E o botão Pagar não deve estar visível
    E o carrinho do usuário deve ter 2 itens
