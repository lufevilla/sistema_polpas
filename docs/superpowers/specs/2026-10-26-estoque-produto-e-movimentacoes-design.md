# Design: Estoque com Produto e Movimentações

**Data**: 2026-10-26
**Objetivo**: Substituir o modelo `StockItem` por `Produto` no estoque e na Home, e registrar cada entrada de estoque em `movimentacao_estoque` por meio de um pop-up com quantidade e valor unitário da compra.

---

## Contexto

O estoque possui duas representações paralelas:

- **Rust `Produto`** (`rust/src/models/pedido.rs`), usado pelo backend e gerado para Dart em `lib/src/rust/models/pedido.dart`.
- **Dart `StockItem`** (`lib/pages/stock/models/stock_item.dart`), usado pela tela de estoque e pela Home.

Hoje o `StockController` converte `Produto` em `StockItem`, e os botões de entrada/saída alteram quantidades diretamente (`increment` com valor fixo, `decrement` com 1). A Home ainda usa uma lista mockada com sua própria classe `StockItem`.

O backend já possui:

- `entrada_no_estoque(id_merc, quantidade_a_adicionar, valor_unitario_compra)`, que atualiza `estoque.quantidade_est` e insere uma linha `ENTRADA` em `movimentacao_estoque`.
- `saida_estoque(quantidade_saida, id_merc)`, que apenas baixa `estoque.quantidade_est`.

**Importante:** este trabalho não altera o backend Rust. A integração usa apenas os services já existentes em `rust/src/api/`.

---

## Decisões de produto

- `estoque.valor_unitario` representa o **preço de venda**.
- `movimentacao_estoque.custo_unitario_compra` representa o **valor de compra** informado na entrada.
- A entrada **não altera** o preço de venda do produto.
- O pop-up de entrada pergunta **quantidade** e **valor unitário da compra**, ambos iniciando **vazios**.
- `+` e `Novo Lote` abrem o mesmo pop-up de entrada.
- A saída (`-`) continua como está: baixa 1 unidade diretamente, sem pop-up e sem registro em `movimentacao_estoque`.
- O pop-up segue o padrão visual dos modais existentes (`stock_form_modal.dart`, `clientes_form_modal.dart`, `sales_form_modal.dart`).

---

## Modelo

### Remover

- `lib/pages/stock/models/stock_item.dart`

### Criar

- `lib/core/models/produto_estoque.dart`
  - `enum StockStatus { high, adequate, attention, low, critical, outOfStock }`
  - `extension StockStatusLabel on StockStatus` com os mesmos rótulos atuais.
  - `extension ProdutoEstoque on Produto`:
    - `double get occupancyRatio` — `quantidadeEst / quantidadeMinima`, com proteção para divisão por zero.
    - `StockStatus get status` — mesma lógica atual baseada na ocupação e em `quantity <= 0`.
    - `bool get isOutOfStock`
    - `bool get isLow` — status `low` ou `critical`.
    - `double get progress` — `occupancyRatio.clamp(0, 1)`.
    - `String get quantityLabel` — ex.: `"12 u."`.

A extensão é compartilhada entre estoque e Home, mantendo as regras de status em um único lugar.

---

## Fluxo de dados

```
SQLite
  → Rust service (listagem_do_estoque)
    → FRB (lib/src/rust/api/estoque_service.dart)
      → StockController / HomeController
        → StockPage / HomePage
```

### Estoque

- `StockController._items` passa a ser `List<Produto>`.
- `carregarEstoque()` chama `svc.listagemDoEstoque()`.
- `registrarEntrada(Produto produto, int quantidade, double valorUnitario)`:
  1. chama `svc.entradaNoEstoque(idMerc: produto.idMerc, quantidadeAAdicionar: quantidade, valorUnitarioCompra: valorUnitario)`;
  2. recarrega o estoque.
- `decrement(Produto produto)` chama `svc.saidaEstoque(quantidadeSaida: 1, idMerc: produto.idMerc)` e recarrega.
- `incluirItem(Produto produto)` chama `svc.incluirItemEstoque(produto: produto)` e recarrega.
- `startNewBatch` deixa de existir; “Novo Lote” usa `registrarEntrada`.

### Home

- Remover a classe mock `StockItem` de `home_controller.dart`.
- `HomeController` expõe `List<Produto> highlightedStock`, `carregando` e `erro`.
- `carregarEstoque()` chama `svc.listagemDoEstoque()`, ordena por menor ocupação e mantém os 2 primeiros itens.
- `HomePage` chama o carregamento no `initState`, adiciona listener no controller e remove no `dispose`.

---

## UI

### Estoque

- `StockPage`:
  - `_abrirModalEntrada(Produto produto)` abre o novo pop-up.
  - `StockItemCard` recebe `Produto`.
  - `onIncrement` e `onNewBatch` chamam `_abrirModalEntrada`.
  - `onDecrement` continua chamando `decrement`.
- `StockItemCard`:
  - usa `Produto.nomeMerc`, `Produto.quantidadeEst`, `Produto.quantidadeMinima` e a extensão de status;
  - remove `packageLabel` (não existe em `Produto`);
  - exibe o preço de venda atual (`valorUnitario`) no lugar da embalagem;
  - mantém o visual atual de status, ocupação e botões.
- Novo `lib/pages/stock/widgets/stock_movimento_modal.dart`:
  - função `mostrarModalEntradaEstoque({context, produto, aoSalvar})`;
  - campos:
    - nome do produto somente leitura;
    - **Quantidade** (`TextInputType.number`), vazio;
    - **Valor unitário da compra (R$)** (`numberWithOptions(decimal: true)`), vazio;
  - validação: quantidade inteira `> 0`; valor decimal `> 0` (aceita vírgula);
  - botão “Registrar entrada”;
  - retorna quantidade e valor via callback, fecha o modal e deixa o controller chamar o service.
- `stock_form_modal.dart` (novo item):
  - remove o campo “Embalagem”;
  - campos: nome, quantidade inicial, quantidade mínima e valor unitário de venda;
  - retorna um `Produto` com `idMerc: 0`.

### Home

- `StockHighlightSection` e `StockItemTile` passam a receber `Produto`.
- Nome, quantidade e barra de progresso usam a extensão `ProdutoEstoque`.
- Cor do placeholder usa uma paleta fixa indexada por `nomeMerc.hashCode` (não existe mais no modelo).
- Exibir estado de carregamento, erro e lista vazia de forma simples, sem quebrar o layout atual.

---

## Tratamento de erros e validação

- Erros dos services continuam preenchendo `_erro` no controller e aparecem na tela, como hoje.
- O pop-up só chama o service se `Form.validate()` passar.
- Entrada com quantidade ou valor inválidos não fecha o modal.
- Saída com estoque insuficiente mantém o erro vindo do Rust (`EstoqueInsuficiente`).

---

## Fora de escopo

- Alterações em qualquer arquivo Rust (`rust/src/**`) ou regeneração de bindings.
- Registro de saída em `movimentacao_estoque`.
- Histórico/listagem de movimentações na interface.
- Alteração do preço de venda a partir da entrada.
- Novos campos no banco de dados.

---

## Verificação

- `flutter analyze` sem erros novos.
- `cd rust && cargo check` sem alterações (garantir que nada do backend foi tocado).
- Verificar manualmente:
  - lista de estoque carrega `Produto`;
  - `+` e `Novo Lote` abrem o pop-up com campos vazios;
  - salvar entrada grava a movimentação e atualiza a quantidade;
  - `-` continua baixando 1 unidade;
  - Home mostra os 2 produtos de menor ocupação vindos do backend;
  - novo item de estoque continua funcionando sem o campo de embalagem.
