use crate::banco_de_dados::database_pd::*;
use crate::models::pedido::{Pedido, ItemPedido};
use crate::error::AppError;

pub async fn criar_pedido(cliente_id: i64, itens: Vec<ItemPedido>) -> Result< (), AppError> {
    let valor_total: f64 = itens.iter().map(|item| item.subtotal()).sum();
    let id_pedido = incluir_pedido_db(cliente_id, valor_total)?;
    for item in &itens {
        incluir_item_pedido_db(item, id_pedido)?;
    }
    Ok(())
}

pub async fn listar_pedidos() -> Result<Vec<Pedido>, AppError> {
    let pedidos = listar_pedidos_db()?;
    Ok(pedidos)
}

pub async fn excluir_pedido(pedido_id: i64) -> Result<(), AppError> {
    excluir_pedido_db(pedido_id)?;
    Ok(())
}


