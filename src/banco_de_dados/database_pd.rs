use rusqlite::{Connection, Result};
use std::{collections::HashMap};
use crate::models::pedido::*;


pub fn incluir_pedido_db(conn_db: &mut Connection,novo_pedido: &Pedido) -> Result<usize>{
    // essa fn retorna o valor do id do pedido para quem a chamou (no caso no arquivo crud_pedido) para que possa repassar para a fn de incluir os itens pedidos no db 
     
    let find_id= conn_db.transaction()?;
    find_id.execute(
    "INSERT INTO pedidos (cliente_id, valor_total) 
        VALUES (?1, ?2)",
    (
        &novo_pedido.cliente_id, 
        &novo_pedido.valor_total,
    ),)?;

    let id_pedido_encontrado:usize = find_id.last_insert_rowid() as usize;//sugestão do gemini
    //eu ia utilizar o query_row pra selecionar o id na linha da tabela, mas o gemini deu essa ideia mais eficiente
    
    find_id.commit()?;

    Ok(id_pedido_encontrado)
}

pub fn incluir_item_pedido_db(conn_db: &Connection,novo_item: &ItemPedido,id_pedido: &usize) -> Result<()>{

conn_db.execute(
        "INSERT INTO itens_pedido (pedido_id, produto_nome,quantidade, valor, subtotal) 
         VALUES (?1, ?2, ?3, ?4, ?5)",
        (
            id_pedido,
            &novo_item.produto_nome,
            &novo_item.quantidade,
            &novo_item.valor,
            &novo_item.subtotal
        ),
    )?;
    Ok(())

}


pub fn listar_pedidos_db(conn_db: &Connection) -> Result<Vec<Pedido>> {
    let mut stmt = conn_db.prepare("
        SELECT 
            pedidos.id_pedidos, 
            pedidos.cliente_id,
            pedidos.valor_total,
            pedidos.data,
            itens_pedido.id_item, 
            itens_pedido.pedido_id,
            itens_pedido.produto_nome, 
            itens_pedido.quantidade,
            itens_pedido.valor,
            itens_pedido.subtotal
        FROM pedidos
        INNER JOIN itens_pedido 
            ON pedidos.id_pedidos = itens_pedido.pedido_id;
    ")?;

    let mut  rows = stmt.query([])?;// cursor que percorrerá a tabela com todos os pedidos

    let mut hashmap_pedidos: HashMap<usize, Pedido> =  HashMap::new();

    while let Some (row) = rows.next()?  {
        
        let id_do_pedido: usize = row.get(0)?;

        let item_do_pedido = ItemPedido{
            id_item: row.get(4)?,
            produto_nome: row.get(6)?,
            quantidade: row.get(7)?,
            valor: row.get(8)?,
            subtotal: row.get(9)?
        };

        let cliente_id_= row.get(1)?;
        let valor_total_= row.get(2)?;
        let data_= row.get(3)?;

        // gemini me deu a dica de usar o entry para acessar uma chave especifica presente no mapa 
        // o método 'or_insert_with' serve para inserir uma nova chave ao mapa apenas se ela não existir 

        hashmap_pedidos.entry(id_do_pedido.clone()).or_insert_with(||
            Pedido{
                id: id_do_pedido,
                cliente_id: cliente_id_,
                valor_total: valor_total_,
                data: data_,
                itens: Vec::new()
            }
        ).itens.push(item_do_pedido);

        
    }

    let vec_pedidos_return: Vec<Pedido> = hashmap_pedidos.into_values().collect();

    Ok(vec_pedidos_return)



}


pub fn excluir_pedido_db(conn_db: &Connection, cliente_id: usize) -> Result<()> {

    conn_db.execute(
        "DELETE FROM pedidos
        WHERE id_pedidos = ?
        LIMIT 1",
    [cliente_id] 
    )?;

    conn_db.execute(
        "DELETE FROM itens_pedido
        WHERE id_item = ?
        LIMIT 1",
    [cliente_id] 
    )?;

    Ok(())
}
