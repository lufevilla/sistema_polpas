# FRB — guia de bolso

## Regra de ouro

**Nunca edite `lib/src/rust/`** — é gerado, toda vez que roda o codegen seu código é sobrescrito.
Pra mudar a API, mexe no Rust e no `lib/rust/` (wrapper manual).

```
rust/src/        → você edita
lib/rust/        → você edita (wrapper)
lib/src/rust/    → GERADO, não mexe
```

---

## Receita: criar uma função nova

### 1. Rust — `rust/src/api/<dominio>_service.rs`

```rust
pub async fn listar_clientes_service() -> Result<Vec<Cliente>, AppError> {
    let clientes = listar_clientes_db()?;
    Ok(clientes)
}
```

- `pub` — senão o codegen ignora
- dentro de `crate::api` — é o que o YAML aponta
- `async` = vira `Future` no Dart. Sem `async` = chamada bloqueante.

### 2. Gerar os bindings

```bash
flutter_rust_bridge_codegen generate
```

### 3. Wrapper — `lib/rust/<dominio>.dart`

```dart
Future<List<Cliente>> listarClientes() {
  return listarClientesService();
}
```

### 4. Chamar no controller

```dart
try {
  final clientes = await rust.listarClientes();
} catch (e) {
  _erro = rust.extrairMensagemErro(e);
}
```

---

## Compilar

```bash
flutter run          # recompila o Rust junto (cargokit)
flutter analyze      # checa o Dart
cd rust && cargo check   # checa o Rust
```

Mudou o `.rs`? O `flutter run` já recompila. Se der erro de símbolo não encontrado, force:
`flutter clean && flutter run`.

---

## Pegadinhas

### `i64` não é `int`

```rust
pub async fn excluir_cliente_service(cliente_id: i64) -> Result<(), AppError>
```

```dart
// gerado:
Future<void> excluirClienteService({required PlatformInt64 clienteId})
```

No wrapper, converta pra `int`:
```dart
Future<void> excluirCliente({required int clienteId}) {
  return excluirClienteService(clienteId: clienteId);
}
```

### `Result` LANÇA, não retorna null

```dart
try {
  await rust.incluirCliente(cliente: c);
} catch (e) {
  // e é AppError (opaco) — use extrairMensagemErro pra virar string
}
```

Pra mensagem em português: use `rust.extrairMensagemErro(e)`.
Pra checar o tipo do erro: `if (e is AppError) { ... }` (import de `lib/src/rust/error.dart`).

### Campo opcional do Rust → nullable no Dart

```rust
pub complemento: Option<String>,   // → String? no Dart
```

### Struct Rust → class Dart com named params

```rust
pub struct Cliente {
    pub id: i64,
    pub nome: String,
    pub endereco: Endereco,
}
```

```dart
rust.Cliente(id: 1, nome: 'João', endereco: rust.Endereco(...))
```

### Função síncrona (não bloqueia a UI? NÃO use em UI)

```rust
#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String { ... }
```

### Erro novo

Adiciona a variant em `rust/src/error.rs` no enum `AppError` com `#[error("mensagem")]`.
O `thiserror` gera o `to_string()` e o `extrair_mensagem_erro` (em `rust/src/api/simple.rs`) já pega.

---

## Onde mexer em cada caso

| Quero... | Arquivo |
|---|---|
| Criar/alterar função de negócio | `rust/src/api/*_service.rs` |
| Alterar query SQL | `rust/src/banco_de_dados/*.rs` |
| Criar variant de erro | `rust/src/error.rs` |
| Criar/alterar struct | `rust/src/models/*.rs` |
| Nome bonito no Dart | `lib/rust/*.dart` |
| Lógica da tela | `lib/pages/*/*_controller.dart` |

---

## Criar model novo (Rust → Dart)

**Rust** `rust/src/models/produto.rs`:
```rust
#[derive(Default, Debug, Clone, Serialize, Deserialize)]
pub struct Produto {
    pub id: i64,
    pub nome: String,
}
```

**Dart**: já sai em `lib/src/rust/models/produto.dart` após o codegen. Só importe e use.

---

## Lembretes de API

```dart
rust.listarClientes()          // Future<List<Cliente>>
rust.incluirCliente(cliente: c)
rust.atualizarCliente(cliente: c, clienteId: id)
rust.excluirCliente(clienteId: id)
rust.extrairMensagemErro(e)     // String
```

Ver tudo: `lib/rust/rust_api.dart` (barrel export).
