# Listar Clientes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar a função de listar todos os clientes, desde a query SQLite no Rust até a API Dart.

**Architecture:** Adicionar `listar_clientes_db()` na camada de banco, `listar_clientes_service()` com `#[frb]` no service, rodar codegen, e adicionar wrapper Dart.

**Tech Stack:** Rust, rusqlite, flutter_rust_bridge 2.13.0, Dart/Flutter

---

## File Structure

```
rust/src/banco_de_dados/database_cl.rs  ← MODIFICAR: adicionar listar_clientes_db()
rust/src/api/clientes_service.rs        ← MODIFICAR: adicionar listar_clientes_service()
lib/rust/clientes.dart                  ← MODIFICAR: adicionar listarClientes()
lib/src/rust/api/clientes_service.dart  ← REGENERADO PELO CODEGEN
```

---

## Task 1: Adicionar listar_clientes_db() no database layer

**Files:**
- Modify: `rust/src/banco_de_dados/database_cl.rs`

- [ ] **Step 1: Adicionar listar_clientes_db()**

Adicionar ao final de `rust/src/banco_de_dados/database_cl.rs`:

```rust
pub fn listar_clientes_db() -> Result<Vec<Cliente>, AppError> {
    let conn_db = obter_conexao()?;
    let mut stmt = conn_db.prepare(
        "SELECT id, nome, cadastro, telefone, cep, logradouro, numero, complemento, bairro, municipio, uf
         FROM clientes"
    )?;

    let clientes = stmt.query_map([], |row| {
        Ok(Cliente {
            id: row.get(0)?,
            nome: row.get(1)?,
            cadastro: row.get(2)?,
            telefone: row.get(3)?,
            endereco: Endereco {
                cep: row.get(4)?,
                logradouro: row.get(5)?,
                numero: row.get(6)?,
                complemento: row.get(7)?,
                bairro: row.get(8)?,
                municipio: row.get(9)?,
                uf: row.get(10)?,
            },
        })
    })?;

    let mut result = Vec::new();
    for cliente in clientes {
        result.push(cliente?);
    }
    Ok(result)
}
```

- [ ] **Step 2: Verificar se compila**

Run: `cargo check` (no diretório rust/)
Expected: Compila sem erros novos

- [ ] **Step 3: Commit**

```bash
git add rust/src/banco_de_dados/database_cl.rs
git commit -m "feat(rust): add listar_clientes_db function"
```

---

## Task 2: Adicionar listar_clientes_service() com FRB

**Files:**
- Modify: `rust/src/api/clientes_service.rs`

- [ ] **Step 1: Adicionar listar_clientes_service()**

Adicionar ao final de `rust/src/api/clientes_service.rs`:

```rust
#[flutter_rust_bridge::frb]
pub async fn listar_clientes_service() -> Result<Vec<Cliente>, AppError> {
    listar_clientes_db()
}
```

- [ ] **Step 2: Verificar se compila**

Run: `cargo check` (no diretório rust/)
Expected: Compila sem erros novos

- [ ] **Step 3: Commit**

```bash
git add rust/src/api/clientes_service.rs
git commit -m "feat(rust): add listar_clientes_service with FRB"
```

---

## Task 3: Rodar codegen FRB

**Files:**
- Generated: `lib/src/rust/api/clientes_service.dart`

- [ ] **Step 1: Rodar codegen**

Run: `flutter_rust_bridge_codegen generate`
Expected: Gera `listarClientesService()` em `lib/src/rust/api/clientes_service.dart`

- [ ] **Step 2: Verificar binding gerado**

Verificar que `lib/src/rust/api/clientes_service.dart` contém:
```dart
Future<List<Cliente>> listarClientesService() => ...
```

- [ ] **Step 3: Verificar que Flutter compila**

Run: `flutter analyze`
Expected: Sem erros novos

- [ ] **Step 4: Commit**

```bash
git add lib/src/rust/
git commit -m "feat(frb): regenerate bindings with listar_clientes"
```

---

## Task 4: Adicionar wrapper Dart listarClientes()

**Files:**
- Modify: `lib/rust/clientes.dart`

- [ ] **Step 1: Adicionar listarClientes()**

Adicionar ao final de `lib/rust/clientes.dart`:

```dart
Future<List<Cliente>> listarClientes() {
  return listarClientesService();
}
```

- [ ] **Step 2: Verificar que Flutter compila**

Run: `flutter analyze`
Expected: Sem erros novos

- [ ] **Step 3: Commit**

```bash
git add lib/rust/clientes.dart
git commit -m "feat(dart): add listarClientes wrapper"
```

---

## Task 5: Verificação final

**Files:** Nenhum arquivo novo

- [ ] **Step 1: Rodar flutter analyze**

Run: `flutter analyze`
Expected: Sem erros novos

- [ ] **Step 2: Verificar que a função está acessível**

Verificar que `listarClientes()` pode ser importada:
```dart
import 'package:sistema_polpas/rust/rustAPI.dart';
// listarClientes() deve estar disponível
```

- [ ] **Step 3: Commit final (se necessário)**

```bash
git add -A
git commit -m "chore: final verification of listar_clientes"
```
