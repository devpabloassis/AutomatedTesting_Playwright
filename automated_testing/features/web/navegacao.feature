# language: pt
@web @regression @feature_catalogo
Funcionalidade: Navegação
  Como visitante
  Quero navegar pelas empresas sem precisar entrar na conta
  Para conhecer as opções antes de comprar

  @smoke
  Cenário: CT-WEB-NAV-001 - Ver empresas sem login
    Dado que não estou logado
    Quando abro a página "/"
    Então devo ver 4 empresas
    E devo ver o link Entrar no cabeçalho
    E o contador do carrinho deve mostrar "0"

  @smoke
  Cenário: CT-WEB-NAV-002 - Abrir cada empresa
    Dado que não estou logado
    Então cada empresa abaixo deve abrir a partir da página inicial com 4 produtos:
      | pizzaria     |
      | hamburgueria |
      | japonesa     |
      | sucos        |

  Cenário: CT-WEB-NAV-003 - Voltar pelo cabeçalho
    Dado que estou na página "/empresas/sucos"
    E devo ver 4 produtos
    Quando clico na marca do cabeçalho
    Então devo ver 4 empresas

  Cenário: CT-WEB-NAV-004 - Voltar pelo navegador
    Dado que estou na página "/"
    Quando clico na empresa "sucos"
    Então devo ver 4 produtos
    Quando volto pelo navegador
    Então devo ver 4 empresas

  Cenário: CT-WEB-NAV-005 - Abrir empresa por URL direta
    Quando abro a página "/empresas/sucos"
    Então o título da página deve ser "Sucos da Fruta"
    E devo ver 4 produtos

  Esquema do Cenário: <id> - <titulo>
    Quando abro a página "<caminho>"
    Então o título da página deve ser "<mensagem>"
    E devo ver o link para voltar às empresas

    Exemplos:
      | id             | titulo              | caminho               | mensagem               |
      | CT-WEB-NAV-006 | Empresa inexistente | /empresas/inexistente | Empresa não encontrada |
      | CT-WEB-NAV-007 | Rota inexistente    | /nao-existe           | Página não encontrada  |

  Cenário: CT-WEB-NAV-008 - Falha ao carregar o catálogo
    Dado que a API responde com erro 500 em "**/api/companies"
    Quando abro a página "/"
    Então devo ver a mensagem "Erro interno."

  @responsive
  Cenário: CT-WEB-NAV-009 - Layout em celular
    Dado que a tela tem largura de 360 pixels
    Quando abro a página "/"
    Então devo ver 4 empresas
    E a página não deve ter rolagem horizontal
