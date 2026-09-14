use thiserror::Error;
    
#[derive(Debug, Error)]
pub enum AppError {
    #[error("Usário já cadastrado com essas informações no sistema.")]
    ClienteJaExiste,

    #[error("Dado inválido! Tente novamente")]
    DadosInvalidos,

    #[error("Campo de informação '{0}' é necessário!")]
    DadosNaoInseridos(String),

    // Converte erros do rusqlite automaticamente em um variante do enum
    #[error("Erro interno no banco de dados: {0}")]
    Database(#[from] rusqlite::Error),
}
