# Design: Função `listar_clientes` — Rust até Dart API

**Data**: 2026-09-14
**Objetivo**: Implementar a função de listar todos os clientes, desde a query SQLite no Rust até a API Dart.

---

## Contexto

O projeto já tem CRUD de clientes (incluir, atualizar, excluir) funcionando em todas as camadas. Falta apenas a operação de leitura (listar todos). Esta função segue o mesmo padrão já estabelecido.

---

## Fluxo de dados

```
Flutter Controller
  → listarClientes()                    (lib/rust/clientes.dart)
    → listarClientesService()           (lib/src/rust/api/clientes_service.dart — FRB gerado)
      → listar_clientes_service()       (rust/src/api/clientes_service.rs — #[frb])
        → listar_clientes_db()          (rust/src/banco_de_dados/database_cl.rs)
          → SELECT * FROM clientes      (SQLite)
```

---

## Camadas

### 1. Database layer

**Arquivo**: `rust/src/banco_de_dados/database_cl.rs`

Adicionar função `listar_clientes_db()`:
- Executa `SELECT id, nome, cadastro, telefone, cep, logradouro, numero, complemento, bairro, municipio, uf FROM clientes`
- Retorna `Result<Vec<Cliente>, AppError>`
- Monta struct `Cliente` com `Endereco` aninhado

### 2. Service layer

**Arquivo**: `rust/src/api/clientes_service.rs`

Adicionar função `listar_clientes_service()`:
- Anotada com `#[flutter_rust_bridge::frb]`
- `async`, retorna `Result<Vec<Cliente>, AppError>`
- Chama `listar_clientes_db()`

### 3. FRB codegen

Rodar `flutter_rust_bridge_codegen generate` para gerar:
- `Future<List<Cliente>> listarClientesService()` em `lib/src/rust/api/clientes_service.dart`

### 4. Wrapper Dart

**Arquivo**: `lib/rust/clientes.dart`

Adicionar função `listarClientes()`:
- `Future<List<Cliente>> listarClientes()`
- Delega para `listarClientesService()`

---

## Arquivos tocados

| Arquivo | Ação |
|---------|------|
| `rust/src/banco_de_dados/database_cl.rs` | Adicionar `listar_clientes_db()` |
| `rust/src/api/clientes_service.rs` | Adicionar `listar_clientes_service()` |
| `lib/rust/clientes.dart` | Adicionar `listarClientes()` |
| `lib/src/rust/api/clientes_service.dart` | Regenerado pelo codegen |

---

## Critérios de sucesso

1. `cargo check` passa
2. `flutter_rust_bridge_codegen generate` gera o binding Dart
3. `flutter analyze` sem erros novos
4. `listarClientes()` é chamável do Dart e retorna `List<Cliente>`
