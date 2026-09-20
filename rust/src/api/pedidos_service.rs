use crate::banco_de_dados::database_pd::*;
use crate::models::pedido::{Pedido, ItemPedido};
use crate::error::AppError;

pub async fn criar_pedido(cliente_id: i64, itens: Vec<ItemPedido>) -> Result<i64, AppError> {
    let valor_total: f64 = itens.iter().map(|item| item.subtotal()).sum();

    let mut pedido = Pedido::default();
    pedido.cliente_id = cliente_id;
    pedido.valor_total = valor_total;

    let pedido_id = incluir_pedido_db(&pedido)?;
    for item in &itens {
        incluir_item_pedido_db(item, &pedido_id)?;
    }

    Ok(pedido_id)
}

pub async fn listar_pedidos() -> Result<Vec<Pedido>, AppError> {
    let pedidos = listar_pedidos_db()?;
    Ok(pedidos)
}

pub async fn excluir_pedido(pedido_id: i64) -> Result<(), AppError> {
    excluir_pedido_db(pedido_id)?;
    Ok(())
}
