# language: pt
@web @regression @feature_catalogo
Funcionalidade: Produtos
  Como visitante
  Quero ver os produtos com seus tamanhos e preços
  Para escolher o que vou pedir

  @smoke
  Cenário: CT-WEB-PRO-001 - Preço padrão com tamanho
    Quando abro a página "/empresas/pizzaria"
    Então o tamanho selecionado do produto "portuguesa" deve ser "P"
    E o preço do produto "portuguesa" deve ser "R$ 38,90"

  Cenário: CT-WEB-PRO-002 - Trocar tamanho da pizza
    Dado que estou na página "/empresas/pizzaria"
    Quando seleciono o tamanho "Médio" do produto "portuguesa"
    Então o preço do produto "portuguesa" deve ser "R$ 52,90"
    Quando seleciono o tamanho "Grande" do produto "portuguesa"
    Então o preço do produto "portuguesa" deve ser "R$ 66,90"

  Cenário: CT-WEB-PRO-003 - Trocar tamanho do suco
    Dado que estou na página "/empresas/sucos"
    Quando seleciono o tamanho "Grande" do produto "laranja"
    Então o preço do produto "laranja" deve ser "R$ 14,90"

  Esquema do Cenário: <id> - <titulo>
    Quando abro a página "/empresas/<empresa>"
    Então o preço do produto "<produto>" deve ser "<preco>"
    E o produto "<produto>" não deve ter seletor de tamanho

    Exemplos:
      | id             | titulo                      | empresa      | produto        | preco    |
      | CT-WEB-PRO-004 | Hambúrguer sem tamanho      | hamburgueria | duplo          | R$ 36,90 |
      | CT-WEB-PRO-005 | Comida japonesa sem tamanho | japonesa     | hot-filadelfia | R$ 29,90 |
