# Conectar Estoque ao Backend Rust - Design

## Objetivo

Conectar a página de estoque (que hoje usa dados mockados) ao backend Rust/SQLite, mantendo a arquitetura existente (page → controller → widgets).

## Contexto

O sistema de estoque tem duas camadas paralelas que não se conectam:
- **Backend Rust**: CRUD completo com SQLite (incluir, entrada, saida, listagem, exclusão)
- **Frontend Dart**: Página com dados hardcoded no `StockController`

## Mapeamento de Modelos

### Rust `Produto` (em `rust/src/models/pedido.rs`)
```rust
pub struct Produto {
    pub id_merc: i64,
    pub nome_merc: String,
    pub quantidade_est: i64,
    pub quantidade_minima: i64,
    pub valor_unitario: f64,
}
```

### Frontend `StockItem` (em `lib/pages/stock/models/stock_item.dart`)
```dart
class StockItem {
  final String id;
  final String name;
  final String packageLabel;
  final int quantity;
  final int capacity;
}
```

### Regras de Conversão
| Rust | Frontend | Regra |
|------|----------|-------|
| `id_merc` | `id` | `id_merc.toString()` |
| `nome_merc` | `name` | direto |
| `quantidade_est` | `quantity` | `.toInt()` |
| `quantidade_minima` | `capacity` | `.toInt()` (usado como referência para status) |
| — | `packageLabel` | hardcoded `"Pacote 1kg"` |
| `valor_unitario` | — | não usado no frontend |

## Arquitetura (respeitar camadas)

```
lib/pages/stock/
├── models/
│   └── stock_item.dart        ← StockItem + factory fromProduto()
├── stock_controller.dart       ← Carrega dados do Rust, gerencia estado
├── stock_page.dart             ← UI (CustomScrollView com grid)
└── widgets/
    ├── stock_item_card.dart    ← Card individual
    ├── stock_form_modal.dart   ← Modal para novo item
    ├── stock_total_card.dart   ← Card total
    ├── stock_low_stock_card.dart ← Card estoque baixo
    └── stock_bestseller_card.dart ← Card mais vendido
```

### Fluxo de Dados
```
SQLite → Rust Service → FRB → Dart Wrapper → StockController → StockPage (UI)
```

### StockController (mudanças)
- `carregarEstoque()` → chama `rust.estoque.carregarEstoque()`, converte `Produto` → `StockItem`
- `increment(id)` → chama `entradaEstoque(idMerc, 1)`, depois recarrega
- `decrement(id)` → chama `saidaEstoque(idMerc, 1)`, depois recarrega
- `startNewBatch(id)` → pode ser implementado como `entradaEstoque` com quantidade = capacidade
- `bestSellerName` → mantém hardcoded por enquanto (não há dados de vendas no backend de estoque)

### Tratamento de Erros
- Erros do Rust → exibir `SnackBar` com mensagem
- Loading state → `CircularProgressIndicator` enquanto carrega
- Lista vazia → mensagem "Nenhum item no estoque"

## Escopo

### INCLUIR
- [ ] Adaptar `StockItem` com factory `fromProduto()`
- [ ] Reescrever `StockController` para usar backend Rust
- [ ] Adicionar loading/error states na `StockPage`
- [ ] Conectar increment/decrement ao backend

### NÃO INCLUIR (por enquanto)
- Modal de novo item (já existe `stock_form_modal.dart`, mas integração pode ser fase futura)
- Bestseller real (precisa de dados de vendas)
- Remoção de itens do estoque
- Validações de estoque negativo no frontend (já tratado no Rust)
