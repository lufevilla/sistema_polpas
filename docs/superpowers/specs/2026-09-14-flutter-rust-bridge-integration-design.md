# Design: Integração Rust ↔ Flutter via flutter_rust_bridge

**Data**: 2026-09-14
**Objetivo**: Preparar o chão para integração completa entre o backend Rust e o frontend Flutter usando flutter_rust_bridge.

---

## Contexto

O projeto `sistema_polpas` possui:
- **Flutter frontend**: Controllers com dados mock, páginas UI funcionando
- **Rust backend**: Services para clientes (parcialmente implementados), estoque e pedidos (comentados), models definidos, SQLite via rusqlite
- **flutter_rust_bridge 2.13.0**: Configurado mas expondo apenas a função `greet`

O objetivo é preparar a infraestrutura para que as funções Rust sejam chamadas do Flutter, sem implementar todas as chamadas ainda.

---

## Arquitetura

### Camadas

```
Flutter UI (pages/)
    ↓
Controllers (pages/*/controller.dart)
    ↓
Wrappers Dart (lib/rust/*.dart)
    ↓
FRB Gerado (lib/src/rust/) — NÃO EDITAR
    ↓ FFI
Services Rust (rust/src/api/*.rs)
    ↓
Database (rust/src/banco_de_dados/*.rs)
    ↓
SQLite
```

### Estrutura de arquivos

```
rust/src/
├── api/
│   ├── simple.rs                    ← init_app + greet (já existe)
│   ├── clientes_service.rs          ← CRUD clientes (já existe, anotar FRB)
│   ├── estoque_service.rs           ← CRUD estoque (já existe, comentado)
│   └── pedidos_service.rs           ← CRUD pedidos (já existe, comentado)
├── models/
│   ├── cliente.rs                   ← Endereco, Cliente (já existe)
│   └── pedido.rs                    ← Produto, ItemPedido, Pedido (já existe)
├── banco_de_dados/
│   ├── create_db.rs                 ← Criação das tabelas (já existe)
│   ├── database_cl.rs               ← Query functions clientes (já existe)
│   ├── database_est.rs              ← Query functions estoque (já existe)
│   └── database_pd.rs               ← Query functions pedidos (já existe)
├── error.rs                         ← AppError enum (já existe)
└── lib.rs                           ← Module declarations (já existe)

lib/rust/                            ← NOVA PASTA
├── clientes.dart                    ← Wrapper para clientes
├── estoque.dart                     ← Wrapper para estoque
├── pedidos.dart                     ← Wrapper para pedidos
└── rustAPI.dart                     ← Barrel export (já existe, vazio)

lib/src/rust/                        ← GERADO PELO FRB (não editar)
├── api/simple.dart
├── frb_generated.dart
└── frb_generated.{io,web}.dart
```

---

## Alterações necessárias

### 1. Models Rust — adicionar anotações FRB

Arquivos: `rust/src/models/cliente.rs`, `rust/src/models/pedido.rs`

- Adicionar `#[frb]` nas structs para que o FRB gere os types Dart correspondentes
- Adicionar `serde::Serialize` e `serde::Deserialize` se necessário para serialização

### 2. Services Rust — descomentar e anotar

Arquivos: `rust/src/api/clientes_service.rs`, `rust/src/api/estoque_service.rs`, `rust/src/api/pedidos_service.rs`

- Descomentar as funções comentadas em estoque e pedidos
- Adicionar `#[flutter_rust_bridge::frb(sync)]` ou `#[flutter_rust_bridge::frb]` nas funções que devem ser expostas
- Manter `init_app()` em `simple.rs` para inicialização

### 3. Codegen FRB

```bash
flutter_rust_bridge_codegen generate
```

Isso gera automaticamente em `lib/src/rust/`:
- Tipos Dart correspondentes aos structs Rust
- Funções Dart que chamam as funções Rust via FFI

### 4. Wrappers Dart

Criar arquivos em `lib/rust/` que:
- Importam o FRB gerado
- Expõem uma API Dart amigável
- Tratam conversão de tipos se necessário
- Exceções Rust são propagadas como exceptions Dart

### 5. Conexão com controllers

Substituir os dados mock nos controllers pelas chamadas aos wrappers.

---

## Configuração existente

### flutter_rust_bridge.yaml (já correto)

```yaml
rust_input: crate::api
rust_root: rust/
dart_output: lib/src/rust
```

### Cargo.toml (dependências Rust)

```toml
flutter_rust_bridge = "=2.13.0"
rusqlite = "0.40.2"
anyhow = "1.0.104"
tokio = { version = "1.53.0", features = ["rt-multi-thread", "macros"] }
thiserror = "2.0"
```

### pubspec.yaml (dependências Flutter)

```yaml
dependencies:
  flutter_rust_bridge: 2.13.0
  rust_lib_sistema_polpas:
    path: rust_builder
```

---

## Onde pegar funções e models do Rust

### Models

| Struct | Arquivo | Linha |
|--------|---------|-------|
| `Endereco` | `rust/src/models/cliente.rs` | 4 |
| `Cliente` | `rust/src/models/cliente.rs` | 16 |
| `Produto` | `rust/src/models/pedido.rs` | 2 |
| `ItemPedido` | `rust/src/models/pedido.rs` | 8 |
| `Pedido` | `rust/src/models/pedido.rs` | 17 |

### Services/Functions

| Função | Arquivo | Linha | Status |
|--------|---------|-------|--------|
| `incluir_cliente_service()` | `rust/src/api/clientes_service.rs` | 5 | Implementada |
| `atualizar_cliente_service()` | `rust/src/api/clientes_service.rs` | 23 | Implementada |
| `excluir_cliente_service()` | `rust/src/api/clientes_service.rs` | 29 | Implementada |
| `entrada_no_estoque()` | `rust/src/api/estoque_service.rs` | 7 | Comentada |
| `listagem_do_estoque()` | `rust/src/api/estoque_service.rs` | 26 | Comentada |
| `incluir_item()` | `rust/src/api/estoque_service.rs` | 40 | Comentada |
| `excluir_item()` | `rust/src/api/estoque_service.rs` | 64 | Comentada |
| `novo_pedido()` | `rust/src/api/pedidos_service.rs` | 9 | Comentada |
| `listar_pedidos()` | `rust/src/api/pedidos_service.rs` | 116 | Comentada |
| `excluir_pedido()` | `rust/src/api/pedidos_service.rs` | 154 | Comentada |

### Erros

| Enum | Arquivo | Linha |
|------|---------|-------|
| `AppError` | `rust/src/error.rs` | 4 |
| `AppError::ClienteJaExiste` | `rust/src/error.rs` | 6 |
| `AppError::DadosInvalidos` | `rust/src/error.rs` | 9 |
| `AppError::DadosNaoInseridos(String)` | `rust/src/error.rs` | 12 |
| `AppError::Database(rusqlite::Error)` | `rust/src/error.rs` | 15 |

---

## Escopo desta fase

- Preparar models Rust com anotações FRB
- Preparar services Rust com anotações FRB (descomentar o necessário)
- Rodar codegen FRB
- Criar wrappers Dart em `lib/rust/`
- Atualizar `lib/main.dart` para inicializar corretamente
- NÃO substituir dados mock nos controllers (fase seguinte)

---

## Critérios de sucesso

1. `flutter_rust_bridge_codegen generate` roda sem erros
2. Funções Rust são chamáveis do Dart
3. Models Rust são representados como tipos Dart
4. Wrappers Dart organizam as chamadas por módulo
5. `lib/main.dart` inicializa o FRB corretamente
