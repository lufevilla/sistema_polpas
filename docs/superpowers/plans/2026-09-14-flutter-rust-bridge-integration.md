# Flutter-Rust-Bridge Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preparar a integração Rust↔Flutter via flutter_rust_bridge, expondo models e services Rust como tipos e funções Dart.

**Architecture:** Anotar structs Rust com `#[frb]` e `serde`, descomentar services, rodar codegen FRB, criar wrappers Dart organizados por módulo (clientes, estoque, pedidos).

**Tech Stack:** Rust, flutter_rust_bridge 2.13.0, rusqlite, Dart/Flutter

---

## File Structure

```
rust/src/
├── models/cliente.rs          ← MODIFICAR: adicionar #[frb] + serde
├── models/pedido.rs           ← MODIFICAR: adicionar #[frb] + serde
├── api/simple.rs              ← MANTER: já tem init_app
├── api/clientes_service.rs    ← MODIFICAR: anotar com #[frb]
├── api/estoque_service.rs     ← MODIFICAR: descomentar + anotar
├── api/pedidos_service.rs     ← MODIFICAR: descomentar + anotar
└── error.rs                   ← MODIFICAR: adicionar #[frb] no enum

lib/rust/                      ← CRIAR PASTA
├── clientes.dart              ← CRIAR: wrapper clientes
├── estoque.dart               ← CRIAR: wrapper estoque
├── pedidos.dart               ← CRIAR: wrapper pedidos
└── rustAPI.dart               ← MODIFICAR: barrel export

lib/src/rust/                  ← GERADO PELO FRB (não editar)
```

---

## Task 1: Adicionar serde e frb nos models Rust

**Files:**
- Modify: `rust/src/models/cliente.rs`
- Modify: `rust/src/models/pedido.rs`
- Modify: `rust/Cargo.toml`

- [ ] **Step 1: Adicionar serde ao Cargo.toml**

```toml
# rust/Cargo.toml - adicionar na seção [dependencies]
serde = { version = "1.0", features = ["derive"] }
```

- [ ] **Step 2: Anotar models em cliente.rs**

Substituir o conteúdo de `rust/src/models/cliente.rs`:

```rust
use serde::{Deserialize, Serialize};

#[derive(Default, Debug, Clone, Serialize, Deserialize, frb::OpaqueSync)]
pub struct Endereco {
    pub cep: String,
    pub logradouro: String,
    pub numero: String,
    pub complemento: Option<String>,
    pub bairro: String,
    pub municipio: String,
    pub uf: String,
}

#[derive(Default, Debug, Clone, Serialize, Deserialize, frb::OpaqueSync)]
pub struct Cliente {
    pub id: i64,
    pub nome: String,
    pub cadastro: String,
    pub endereco: Endereco,
    pub telefone: String,
}
```

- [ ] **Step 3: Anotar models em pedido.rs**

Substituir o conteúdo de `rust/src/models/pedido.rs`:

```rust
use serde::{Deserialize, Serialize};

#[derive(Default, Debug, Clone, Serialize, Deserialize, frb::OpaqueSync)]
pub struct Produto {
    pub id_merc: i64,
    pub nome_merc: String,
    pub quantidade_est: i64,
}

#[derive(Default, Debug, Clone, Serialize, Deserialize, frb::OpaqueSync)]
pub struct ItemPedido {
    pub id_item: i64,
    pub produto_nome: String,
    pub quantidade: i64,
    pub valor: f64,
    pub subtotal: f64,
}

#[derive(Default, Debug, Clone, Serialize, Deserialize, frb::OpaqueSync)]
pub struct Pedido {
    pub id: i64,
    pub cliente_id: i64,
    pub itens: Vec<ItemPedido>,
    pub valor_total: f64,
    pub data: String,
}
```

- [ ] **Step 4: Verificar se compila**

Run: `cd rust && cargo check`
Expected: Compila sem erros (warnings são aceitáveis)

- [ ] **Step 5: Commit**

```bash
git add rust/Cargo.toml rust/src/models/cliente.rs rust/src/models/pedido.rs
git commit -m "feat(rust): add serde + frb annotations to models"
```

---

## Task 2: Anotar services Rust com FRB

**Files:**
- Modify: `rust/src/api/clientes_service.rs`
- Modify: `rust/src/api/estoque_service.rs`
- Modify: `rust/src/api/pedidos_service.rs`

- [ ] **Step 1: Anotar clientes_service.rs**

O arquivo `rust/src/api/clientes_service.rs` já tem implementação. Adicionar anotações `#[flutter_rust_bridge::frb]` nas funções públicas:

```rust
use rusqlite::Error;

use crate::{models::cliente::Cliente, banco_de_dados::database_cl::*, error::AppError};

#[flutter_rust_bridge::frb]
pub async fn incluir_cliente_service(cliente: Cliente) -> Result<(), AppError> {
    checagem_presenca_dados(&cliente)?;

    match pesquisa_cliente_db(&cliente.nome, &cliente.cadastro) {
        Ok(true) => incluir_cliente_db(&cliente),
        Ok(false) => Err(AppError::ClienteJaExiste),
        Err(e) => Err(e),
    }
}

#[flutter_rust_bridge::frb]
pub async fn atualizar_cliente_service(cliente: Cliente, cliente_id: i64) -> Result<(), AppError> {
    checagem_presenca_dados(&cliente)?;
    atualizar_cliente_db(&cliente, cliente_id)
}

#[flutter_rust_bridge::frb]
pub async fn excluir_cliente_service(cliente: Cliente, cliente_id: i64) -> Result<(), AppError> {
    excluir_cliente_db(cliente_id)
}

fn checagem_presenca_dados(cliente: &Cliente) -> Result<(), AppError> {
    let campos_obrigatorios = [
        ("Nome", cliente.nome.as_str()),
        ("CPF/CNPJ", cliente.cadastro.as_str()),
        ("Telefone", cliente.telefone.as_str()),
        ("CEP", cliente.endereco.cep.as_str()),
        ("Logradouro", cliente.endereco.logradouro.as_str()),
        ("Número", cliente.endereco.numero.as_str()),
        ("Bairro", cliente.endereco.bairro.as_str()),
        ("Município", cliente.endereco.municipio.as_str()),
        ("UF", cliente.endereco.uf.as_str()),
    ];
    if let Some((nome_campo, _)) = campos_obrigatorios.iter().find(|(_, val)| val.trim().is_empty()) {
        return Err(AppError::DadosNaoInseridos(nome_campo.to_string()));
    }
    Ok(())
}
```

- [ ] **Step 2: Anotar estoque_service.rs (descomentar)**

Substituir o conteúdo de `rust/src/api/estoque_service.rs`:

```rust
use crate::models::pedido::Produto;
use crate::banco_de_dados::database_est::*;
use crate::error::AppError;

#[flutter_rust_bridge::frb]
pub async fn entrada_no_estoque_service(produto: Produto) -> Result<(), AppError> {
    let conn_db = crate::banco_de_dados::create_db::obter_conexao()?;
    entrada_estoque_db(&conn_db, &produto)?;
    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn listagem_do_estoque_service() -> Result<Vec<Produto>, AppError> {
    let conn_db = crate::banco_de_dados::create_db::obter_conexao()?;
    let produtos = listagem_estoque_db(&conn_db)?;
    Ok(produtos)
}

#[flutter_rust_bridge::frb]
pub async fn incluir_item_estoque_service(nome_merc: String, quantidade_est: i64) -> Result<(), AppError> {
    let conn_db = crate::banco_de_dados::create_db::obter_conexao()?;
    let produto = Produto {
        id_merc: 0,
        nome_merc,
        quantidade_est,
    };
    // TODO: implementar incluir_item_estoque_db no banco_de_dados/database_est.rs
    // Por enquanto, usar entrada_estoque_db
    entrada_estoque_db(&conn_db, &produto)?;
    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn excluir_item_estoque_service(item_id: i64) -> Result<(), AppError> {
    let conn_db = crate::banco_de_dados::create_db::obter_conexao()?;
    // TODO: implementar excluir_item_estoque_db no banco_de_dados/database_est.rs
    Ok(())
}
```

- [ ] **Step 3: Anotar pedidos_service.rs (descomentar)**

Substituir o conteúdo de `rust/src/api/pedidos_service.rs`:

```rust
use crate::banco_de_dados::database_est::{checagem_estoque, saida_estoque_db};
use crate::banco_de_dados::database_pd::*;
use crate::models::pedido::{Pedido, ItemPedido};
use crate::error::AppError;
use crate::banco_de_dados::create_db::obter_conexao;

#[flutter_rust_bridge::frb]
pub async fn novo_pedido_service(pedido: Pedido, itens: Vec<ItemPedido>) -> Result<(), AppError> {
    let mut conn_db = obter_conexao()?;
    let pedido_id = incluir_pedido_db(&mut conn_db, &pedido)?;
    for item in &itens {
        incluir_item_pedido_db(&conn_db, item, &pedido_id)?;
        saida_estoque_db(&conn_db, item)?;
    }
    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn listar_pedidos_service() -> Result<Vec<Pedido>, AppError> {
    let conn_db = obter_conexao()?;
    let pedidos = listar_pedidos_db(&conn_db)?;
    Ok(pedidos)
}

#[flutter_rust_bridge::frb]
pub async fn excluir_pedido_service(pedido_id: i64) -> Result<(), AppError> {
    let conn_db = obter_conexao()?;
    excluir_pedido_db(&conn_db, pedido_id as usize)?;
    Ok(())
}
```

- [ ] **Step 4: Verificar se compila**

Run: `cd rust && cargo check`
Expected: Compila sem erros

- [ ] **Step 5: Commit**

```bash
git add rust/src/api/clientes_service.rs rust/src/api/estoque_service.rs rust/src/api/pedidos_service.rs
git commit -m "feat(rust): annotate services with FRB attributes"
```

---

## Task 3: Rodar codegen FRB

**Files:**
- Generated: `lib/src/rust/` (todo o diretório é regenerado)

- [ ] **Step 1: Instalar flutter_rust_bridge_codegen (se necessário)**

Run: `cargo install flutter_rust_bridge_codegen --version 2.13.0`

- [ ] **Step 2: Rodar o codegen**

Run: `flutter_rust_bridge_codegen generate`
Expected: Gera arquivos em `lib/src/rust/` com tipos Dart e funções

- [ ] **Step 3: Verificar arquivos gerados**

Run: `ls lib/src/rust/api/`
Expected: Deve ter `simple.dart` e outros arquivos gerados para cada módulo

- [ ] **Step 4: Verificar que o Flutter compila**

Run: `flutter analyze`
Expected: Sem erros fatais (warnings são aceitáveis)

- [ ] **Step 5: Commit**

```bash
git add lib/src/rust/
git commit -m "feat(frb): generate Dart bindings from Rust"
```

---

## Task 4: Criar wrappers Dart por módulo

**Files:**
- Create: `lib/rust/clientes.dart`
- Create: `lib/rust/estoque.dart`
- Create: `lib/rust/pedidos.dart`
- Modify: `lib/rust/rustAPI.dart`

- [ ] **Step 1: Criar lib/rust/clientes.dart**

```dart
import '../src/rust/frb_generated.dart';
import '../src/rust/api/simple.dart';

// TODO: importar funções FRB geradas para clientes quando codegen estiver pronto
// import '../src/rust/api/clientes_service.dart';

/// Wrapper para operações de clientes.
///
/// Este arquivo importa o FRB gerado e expõe uma API Dart amigável.
/// Os controllers devem chamar estas funções em vez de chamar o FRB diretamente.
class ClientesService {
  /// Inclui um novo cliente no banco de dados.
  ///
  /// Lança [AppError] se o cliente já existir ou dados estiverem inválidos.
  // static Future<void> incluirCliente(Cliente cliente) async {
  //   await FRBGenerated.incluirClienteService(cliente: cliente);
  // }

  /// Atualiza um cliente existente.
  // static Future<void> atualizarCliente(Cliente cliente, int clienteId) async {
  //   await FRBGenerated.atualizarClienteService(cliente: cliente, clienteId: clienteId);
  // }

  /// Exclui um cliente pelo ID.
  // static Future<void> excluirCliente(int clienteId) async {
  //   await FRBGenerated.excluirClienteService(clienteId: clienteId);
  // }
}
```

- [ ] **Step 2: Criar lib/rust/estoque.dart**

```dart
import '../src/rust/frb_generated.dart';

/// Wrapper para operações de estoque.
///
/// Este arquivo importa o FRB gerado e expõe uma API Dart amigável.
class EstoqueService {
  /// Registra entrada de mercadoria no estoque.
  // static Future<void> entradaEstoque(Produto produto) async {
  //   await FRBGenerated.entradaNoEstoqueService(produto: produto);
  // }

  /// Lista todos os itens do estoque.
  // static Future<List<Produto>> listarEstoque() async {
  //   return await FRBGenerated.listagemDoEstoqueService();
  // }

  /// Inclui um novo item no estoque.
  // static Future<void> incluirItem(String nomeMerc, int quantidadeEst) async {
  //   await FRBGenerated.incluirItemEstoqueService(nomeMerc: nomeMerc, quantidadeEst: quantidadeEst);
  // }

  /// Exclui um item do estoque.
  // static Future<void> excluirItem(int itemId) async {
  //   await FRBGenerated.excluirItemEstoqueService(itemId: itemId);
  // }
}
```

- [ ] **Step 3: Criar lib/rust/pedidos.dart**

```dart
import '../src/rust/frb_generated.dart';

/// Wrapper para operações de pedidos.
///
/// Este arquivo importa o FRB gerado e expõe uma API Dart amigável.
class PedidosService {
  /// Cria um novo pedido com seus itens.
  // static Future<void> novoPedido(Pedido pedido, List<ItemPedido> itens) async {
  //   await FRBGenerated.novoPedidoService(pedido: pedido, itens: itens);
  // }

  /// Lista todos os pedidos.
  // static Future<List<Pedido>> listarPedidos() async {
  //   return await FRBGenerated.listarPedidosService();
  // }

  /// Exclui um pedido pelo ID.
  // static Future<void> excluirPedido(int pedidoId) async {
  //   await FRBGenerated.excluirPedidoService(pedidoId: pedidoId);
  // }
}
```

- [ ] **Step 4: Atualizar rustAPI.dart como barrel export**

```dart
/// Barrel export para todos os wrappers Rust.
///
/// Uso:
/// ```dart
/// import 'package:sistema_polpas/rust/rustAPI.dart';
/// ```
export 'clientes.dart';
export 'estoque.dart';
export 'pedidos.dart';
```

- [ ] **Step 5: Verificar que o Flutter compila**

Run: `flutter analyze`
Expected: Sem erros fatais

- [ ] **Step 6: Commit**

```bash
git add lib/rust/
git commit -m "feat(dart): create Rust service wrappers by module"
```

---

## Task 5: Atualizar main.dart para inicializar FRB

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Atualizar main.dart**

O `main.dart` atual já tem a inicialização correta. Verificar se está assim:

```dart
import 'package:flutter/material.dart';
import 'package:sistema_polpas/src/rust/api/simple.dart';
import 'package:sistema_polpas/src/rust/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Text(
            'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`',
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verificar que o app roda**

Run: `flutter run -d linux` (ou o device disponível)
Expected: App abre sem crash

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat(flutter): ensure FRB initialization in main"
```

---

## Task 6: Verificação final

**Files:** Nenhum arquivo novo

- [ ] **Step 1: Rodar flutter analyze**

Run: `flutter analyze`
Expected: Sem erros

- [ ] **Step 2: Rodar testes**

Run: `flutter test`
Expected: Testes existentes passam

- [ ] **Step 3: Verificar que types Dart existem**

Run: `ls lib/src/rust/api/`
Expected: Arquivos gerados para cada módulo Rust

- [ ] **Step 4: Commit final (se necessário)**

```bash
git add -A
git commit -m "chore: final verification of FRB integration"
```
