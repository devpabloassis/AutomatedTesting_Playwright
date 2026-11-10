# language: pt
@web @regression @feature_carrinho
Funcionalidade: Carrinho
  Como cliente
  Quero revisar, alterar e excluir os itens do carrinho
  Para ajustar meu pedido

  @smoke
  Cenário: CT-WEB-CAR-001 - Exibir dados do item
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    Quando abro a página "/carrinho"
    Então a linha do item "portuguesa/M" deve exibir:
      | Portuguesa           |
      | Pizzaria Forno Nobre |
      | Médio                |
      | R$ 52,90             |
    E a quantidade do item "portuguesa/M" na tela deve ser "1"
    E o subtotal do item "portuguesa/M" deve ser "R$ 52,90"
    E o total do carrinho deve ser "R$ 52,90"

  Cenário: CT-WEB-CAR-002 - Carrinho vazio
    Dado que estou logado com um usuário novo
    Quando abro a página "/carrinho"
    Então devo ver o aviso de carrinho vazio
    E devo ver o link Ver empresas

  Cenário: CT-WEB-CAR-003 - Carrinho sem login
    Dado que não estou logado
    Quando abro a página "/carrinho"
    Então devo ver o aviso de login do carrinho "Entre na sua conta para ver o carrinho."
    E devo ver o botão Entrar do carrinho

  # Falha prevista: BUG-02.
  @smoke @known_bug
  Cenário: CT-WEB-CAR-004 - Alterar quantidade
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/carrinho"
    Quando altero a quantidade do item "portuguesa/M" para "3"
    Então o total do carrinho não deve ser mais "R$ 52,90"
    E a quantidade do item "portuguesa/M" na tela deve ser "3"

  # Falha prevista: BUG-02.
  @known_bug
  Cenário: CT-WEB-CAR-005 - Recalcular valores
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/carrinho"
    Quando altero a quantidade do item "portuguesa/M" para "3"
    Então o total do carrinho não deve ser mais "R$ 52,90"
    E o subtotal do item "portuguesa/M" deve ser "R$ 158,70"
    E o total do carrinho deve ser "R$ 158,70"
    E o contador do carrinho deve mostrar "3"

  Esquema do Cenário: <id> - <titulo>
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/carrinho"
    Quando altero a quantidade do item "portuguesa/M" para "<valor>"
    Então devo ver a mensagem "A quantidade deve ser um número inteiro de 1 a 99."
    E a quantidade do item no carrinho deve ser 1

    Exemplos:
      | id             | titulo                     | valor |
      | CT-WEB-CAR-006 | Quantidade zero            | 0     |
      | CT-WEB-CAR-007 | Quantidade acima do máximo | 100   |
      | CT-WEB-CAR-008 | Quantidade negativa        | -1    |
      | CT-WEB-CAR-009 | Quantidade decimal         | 1.5   |
      | CT-WEB-CAR-010 | Quantidade vazia           |       |

  @smoke
  Cenário: CT-WEB-CAR-011 - Excluir um de vários itens
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que o carrinho do usuário tem o item "pizzaria/calabresa/P"
    E que estou na página "/carrinho"
    Quando excluo o item "calabresa/P"
    Então o item "calabresa/P" não deve estar no carrinho
    E o total do carrinho deve ser "R$ 52,90"
    E o contador do carrinho deve mostrar "1"

  Cenário: CT-WEB-CAR-012 - Excluir o último item
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/carrinho"
    Quando excluo o item "portuguesa/M"
    Então devo ver o aviso de carrinho vazio
    E o contador do carrinho deve mostrar "0"

  Cenário: CT-WEB-CAR-013 - Carrinhos independentes
    Dado que existe outro usuário novo com o item "pizzaria/portuguesa/M"
    E que estou logado com um usuário novo
    Quando abro a página "/carrinho"
    Então devo ver o aviso de carrinho vazio

  Cenário: CT-WEB-CAR-014 - Carrinho mantido
    Dado que existe um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/login"
    Quando faço login com o usuário criado
    Então devo ver o usuário criado no cabeçalho
    Quando abro a página "/carrinho"
    Então devo ver o item "portuguesa/M" no carrinho
    Quando recarrego a página
    Então devo ver o item "portuguesa/M" no carrinho
    Quando clico em Sair
    Então devo ver 4 empresas
    Quando abro a página "/login"
    E faço login com o usuário criado
    Então devo ver o usuário criado no cabeçalho
    Quando abro a página "/carrinho"
    Então devo ver o item "portuguesa/M" no carrinho
