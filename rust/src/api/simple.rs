use crate::banco_de_dados::create_db::create_database;
use crate::error::AppError;

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
    if let Err(erro) = create_database() {
        eprintln!("Falha ao preparar o banco de dados: {erro}");
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn extrair_mensagem_erro(erro: AppError) -> String {
    erro.to_string()
}
