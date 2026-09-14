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
