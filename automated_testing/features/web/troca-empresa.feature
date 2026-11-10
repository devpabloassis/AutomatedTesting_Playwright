# language: pt
@web @regression @feature_troca_empresa
Funcionalidade: Troca de empresa
  Como cliente
  Quero ser avisado ao escolher produto de outra empresa
  Para decidir se troco o pedido

  Contexto:
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/empresas/hamburgueria"
    E o contador do carrinho deve mostrar "1"

  @smoke
  Cenário: CT-WEB-TRO-001 - Exibir aviso
    Quando adiciono o produto "duplo" ao carrinho
    Então o aviso de troca de empresa deve exibir o texto "o carrinho será limpo"
    E o aviso de troca de empresa deve ter as opções Sim e Não

  # Falha prevista: BUG-01.
  @smoke @known_bug
  Cenário: CT-WEB-TRO-002 - Confirmar com Sim limpa o carrinho
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Sim"
    Então devo ver a mensagem "Produto adicionado ao carrinho."
    E o carrinho do usuário deve conter somente os produtos "duplo"
    Quando abro a página "/carrinho"
    Então devo ver o item "duplo/U" no carrinho
    E o item "portuguesa/M" não deve estar no carrinho

  @smoke
  Cenário: CT-WEB-TRO-003 - Recusar com Não
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Não"
    Então o aviso de troca de empresa não deve estar visível
    E o contador do carrinho deve mostrar "1"
    E o carrinho do usuário deve conter somente os produtos "portuguesa"

  Cenário: CT-WEB-TRO-004 - Fechar aviso com Esc
    Quando adiciono o produto "duplo" ao carrinho
    E fecho o aviso com a tecla Esc
    Então o aviso de troca de empresa não deve estar visível
    E o contador do carrinho deve mostrar "1"
    E o carrinho do usuário deve conter somente os produtos "portuguesa"

  Cenário: CT-WEB-TRO-005 - Esc depois de um Sim anterior
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Sim"
    Então devo ver a mensagem "Produto adicionado ao carrinho."
    Quando navego pelo site até a empresa "sucos"
    E guardo o estado do carrinho
    E adiciono o produto "laranja" ao carrinho
    E fecho o aviso com a tecla Esc
    Então o aviso de troca de empresa não deve estar visível
    E o carrinho do usuário não deve ter mudado

  # Contador (badge) do carrinho após a troca de empresa.
  # O contador mostra a soma das quantidades do carrinho retornado pela API.

  # Falha prevista: BUG-01.
  @smoke @known_bug
  Cenário: CT-WEB-TRO-006 - Contador após Sim
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Sim"
    Então devo ver a mensagem "Produto adicionado ao carrinho."
    E o contador do carrinho deve mostrar "1"

  # Falha prevista: BUG-01.
  @known_bug
  Cenário: CT-WEB-TRO-007 - Contador após Sim com várias unidades
    Dado que o carrinho do usuário tem o item "pizzaria/calabresa/P" com quantidade 2
    Quando recarrego a página
    Então o contador do carrinho deve mostrar "3"
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Sim"
    Então devo ver a mensagem "Produto adicionado ao carrinho."
    E o contador do carrinho deve mostrar "1"

  # Falha prevista: BUG-01.
  @known_bug
  Cenário: CT-WEB-TRO-008 - Contador após Sim e recarregar a página
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Sim"
    Então devo ver a mensagem "Produto adicionado ao carrinho."
    Quando recarrego a página
    Então o contador do carrinho deve mostrar "1"
    Quando abro a página "/carrinho"
    Então o contador do carrinho deve mostrar "1"

  # Falha prevista: BUG-01.
  @known_bug
  Cenário: CT-WEB-TRO-009 - Contador após Sim e nova adição da mesma empresa
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Sim"
    Então devo ver a mensagem "Produto adicionado ao carrinho."
    Quando adiciono o produto "completo" ao carrinho
    Então o aviso de troca de empresa não deve estar visível
    E o contador do carrinho deve mostrar "2"

  Cenário: CT-WEB-TRO-010 - Contador coerente com o carrinho após Sim
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Sim"
    Então devo ver a mensagem "Produto adicionado ao carrinho."
    E o contador do carrinho deve corresponder ao carrinho do usuário
    Quando abro a página "/carrinho"
    Então o contador do carrinho deve corresponder ao carrinho do usuário

  Cenário: CT-WEB-TRO-011 - Contador após Não com várias unidades
    Dado que o carrinho do usuário tem o item "pizzaria/calabresa/P" com quantidade 2
    Quando recarrego a página
    Então o contador do carrinho deve mostrar "3"
    Quando adiciono o produto "duplo" ao carrinho
    E confirmo a troca de empresa com "Não"
    Então o aviso de troca de empresa não deve estar visível
    E o contador do carrinho deve mostrar "3"
