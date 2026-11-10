# language: pt
@web @regression @feature_login
Funcionalidade: Login
  Como cliente
  Quero entrar com usuário e senha
  Para usar meu carrinho

  @smoke
  Cenário: CT-WEB-LOG-001 - Login válido
    Dado que existe um usuário novo
    E que estou na página "/login"
    Quando faço login com o usuário criado
    Então devo ver 4 empresas
    E devo ver o usuário criado no cabeçalho
    E devo ver o botão Sair

  Cenário: CT-WEB-LOG-002 - Login dos pré-cadastrados
    Então cada usuário abaixo deve conseguir entrar e sair com a senha "loveMetalSongs@":
      | user_manual |
      | user_robot  |
      | user_hybrid |
      | user_fail   |

  Cenário: CT-WEB-LOG-003 - Sessão mantida
    Dado que estou logado com um usuário novo
    Quando abro a página "/"
    Então devo ver o usuário criado no cabeçalho
    Quando recarrego a página
    Então devo ver o usuário criado no cabeçalho

  @smoke
  Cenário: CT-WEB-LOG-004 - Retorno à empresa
    Dado que existe um usuário novo
    E que estou na página "/empresas/pizzaria"
    Quando adiciono o produto "portuguesa" ao carrinho
    Então devo estar na página de login
    Quando faço login com o usuário criado
    Então devo estar na página "/empresas/pizzaria"
    E devo ver o usuário criado no cabeçalho
    E o carrinho do usuário deve ter 0 itens

  Cenário: CT-WEB-LOG-005 - Retorno ao carrinho
    Dado que existe um usuário novo
    E que estou na página "/carrinho"
    Quando clico no botão Entrar do carrinho
    E faço login com o usuário criado
    Então devo estar na página "/carrinho"

  @smoke
  Cenário: CT-WEB-LOG-006 - Sair
    Dado que estou logado com um usuário novo
    E que o carrinho do usuário tem o item "pizzaria/portuguesa/M"
    E que estou na página "/"
    E o contador do carrinho deve mostrar "1"
    Quando clico em Sair
    Então devo ver o link Entrar no cabeçalho
    E o contador do carrinho deve mostrar "0"
    E devo estar na página "/"

  Cenário: CT-WEB-LOG-007 - Abrir login já logado
    Dado que estou logado com um usuário novo
    Quando abro a página "/login"
    Então devo ver 4 empresas
    E devo estar na página "/"

  @smoke
  Cenário: CT-WEB-LOG-008 - Senha incorreta
    Dado que estou na página "/login"
    Quando faço login com o usuário "user_manual" e a senha "senhaErrada1"
    Então devo ver a mensagem "Usuário ou senha inválidos."
    E não devo estar logado

  Cenário: CT-WEB-LOG-009 - Usuário inexistente
    Dado que estou na página "/login"
    Quando faço login com um usuário inexistente e a senha "loveMetalSongs@"
    Então devo ver a mensagem "Usuário ou senha inválidos."
    E não devo estar logado

  Cenário: CT-WEB-LOG-010 - Campos vazios
    Dado que monitoro as requisições de login
    E que estou na página "/login"
    Quando clico em Entrar sem preencher os campos
    Então o campo usuário deve estar em foco
    E devo estar na página "/login"
    E nenhuma requisição de login deve ter sido enviada

  @security
  Cenário: CT-WEB-LOG-011 - Retorno externo bloqueado
    Dado que estou na página "/login?next=//exemplo.com"
    Quando faço login com o usuário "user_manual" e a senha "loveMetalSongs@"
    Então devo ver 4 empresas
    E devo continuar no sistema
