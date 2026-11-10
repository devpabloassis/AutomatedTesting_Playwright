# language: pt
@api @regression @feature_catalogo
Funcionalidade: Catálogo
  Como consumidor da API
  Quero consultar empresas e produtos
  Para exibir o catálogo aos clientes

  @smoke
  Cenário: CT-API-CAT-001 - Listar empresas
    Quando envio "GET" para "/companies"
    Então o status da resposta deve ser 200
    E a resposta deve ter 4 empresas com 4 produtos cada

  Cenário: CT-API-CAT-002 - Preços do catálogo
    Então os preços do catálogo em centavos devem ser:
      | empresa      | produto          | precos         |
      | pizzaria     | portuguesa       | 3890,5290,6690 |
      | pizzaria     | calabresa        | 3490,4890,6290 |
      | pizzaria     | frango-catupiry  | 3690,5090,6490 |
      | pizzaria     | marguerita       | 3290,4690,6090 |
      | hamburgueria | vegano           | 3190           |
      | hamburgueria | completo         | 2990           |
      | hamburgueria | eggburguer       | 2690           |
      | hamburgueria | duplo            | 3690           |
      | japonesa     | yakissoba-carne  | 3490           |
      | japonesa     | yakissoba-frango | 3190           |
      | japonesa     | yakissoba-misto  | 3790           |
      | japonesa     | hot-filadelfia   | 2990           |
      | sucos        | laranja          | 890,1190,1490  |
      | sucos        | abacaxi          | 990,1290,1590  |
      | sucos        | goiaba           | 950,1250,1550  |
      | sucos        | acerola          | 900,1200,1500  |

  Cenário: CT-API-CAT-003 - Consultar cada empresa
    Então cada empresa abaixo deve ser retornada na consulta pelo seu id:
      | pizzaria     |
      | hamburgueria |
      | japonesa     |
      | sucos        |

  Cenário: CT-API-CAT-004 - Opções por tamanho
    Então os produtos das empresas "pizzaria, sucos" devem ter as opções "P, M, G"

  Cenário: CT-API-CAT-005 - Opção única
    Então os produtos das empresas "hamburgueria, japonesa" devem ter as opções "U"

  Esquema do Cenário: <id> - <titulo>
    Quando envio "GET" para "/companies/<empresa>"
    Então a resposta deve ser um erro 404 com o código "COMPANY_NOT_FOUND"

    Exemplos:
      | id             | titulo                | empresa     |
      | CT-API-CAT-006 | Empresa inexistente   | inexistente |
      | CT-API-CAT-007 | Maiúsculas diferentes | Pizzaria    |
