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
    entrada_estoque_db(&conn_db, &produto)?;
    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn excluir_item_estoque_service(_item_id: i64) -> Result<(), AppError> {
    let _conn_db = crate::banco_de_dados::create_db::obter_conexao()?;
    // TODO: implementar excluir_item_estoque_db no banco_de_dados/database_est.rs
    Ok(())
}
