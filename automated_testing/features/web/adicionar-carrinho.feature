# language: pt
@web @regression @feature_carrinho
Funcionalidade: Adicionar ao carrinho
  Como cliente
  Quero adicionar produtos ao carrinho
  Para montar meu pedido

  @smoke
  Cenário: CT-WEB-ADD-001 - Adicionar em carrinho vazio
    Dado que estou logado com um usuário novo
    E que estou na página "/empresas/pizzaria"
    Quando seleciono o tamanho "Médio" do produto "portuguesa"
    E adiciono o produto "portuguesa" ao carrinho
    Então devo ver a mensagem "Produto adicionado ao carrinho."
    E o contador do carrinho deve mostrar "1"
    E o carrinho do usuário deve conter o item "pizzaria/portuguesa/M" com quantidade 1

  Cenário: CT-WEB-ADD-002 - Mesma empresa, outro produto
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/empresas/pizzaria"
    E o contador do carrinho deve mostrar "1"
    Quando adiciono o produto "calabresa" ao carrinho
    Então o contador do carrinho deve mostrar "2"
    E o aviso de troca de empresa não deve estar visível
    E o carrinho do usuário deve ter 2 itens

  Cenário: CT-WEB-ADD-003 - Mesmo produto e tamanho
    Dado que estou logado com um usuário novo
    E que estou na página "/empresas/hamburgueria"
    Quando adiciono o produto "duplo" ao carrinho
    Então o contador do carrinho deve mostrar "1"
    Quando adiciono o produto "duplo" ao carrinho
    Então o contador do carrinho deve mostrar "2"
    E o carrinho do usuário deve ter 1 item
    E o carrinho do usuário deve conter o item "hamburgueria/duplo/U" com quantidade 2

  Cenário: CT-WEB-ADD-004 - Mesmo produto, outro tamanho
    Dado que estou logado com um usuário novo
    E que estou na página "/empresas/sucos"
    Quando seleciono o tamanho "Pequeno" do produto "laranja"
    E adiciono o produto "laranja" ao carrinho
    Então o contador do carrinho deve mostrar "1"
    Quando seleciono o tamanho "Grande" do produto "laranja"
    E adiciono o produto "laranja" ao carrinho
    Então o contador do carrinho deve mostrar "2"
    E o carrinho do usuário deve ter 2 itens

  @smoke
  Cenário: CT-WEB-ADD-005 - Adicionar sem login
    Dado que não estou logado
    E que estou na página "/empresas/pizzaria"
    Quando adiciono o produto "portuguesa" ao carrinho
    Então devo estar na página de login
    E devo ver a mensagem "Entre na sua conta para adicionar produtos ao carrinho."

  Cenário: CT-WEB-ADD-006 - Limite de quantidade
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "hamburgueria/duplo/U" com quantidade 99
    E que estou na página "/empresas/hamburgueria"
    Quando adiciono o produto "duplo" ao carrinho
    Então devo ver a mensagem "A quantidade do item não pode passar de 99."
    E a quantidade do item no carrinho deve ser 99

  Cenário: CT-WEB-ADD-007 - Falha da API ao adicionar
    Dado que estou logado com um usuário novo
    E que a API responde com erro 500 em "**/cart/items"
    E que estou na página "/empresas/hamburgueria"
    Quando adiciono o produto "duplo" ao carrinho
    Então devo ver a mensagem "Erro interno."
    E o contador do carrinho deve mostrar "0"

  Cenário: CT-WEB-ADD-008 - Sessão de usuário inexistente
    Dado que a sessão do navegador é de um usuário inexistente
    E que estou na página "/empresas/hamburgueria"
    Quando adiciono o produto "duplo" ao carrinho
    Então devo ver a mensagem "Usuário não encontrado."
