use rusqlite::{Connection, Result};
use crate::models::pedido::*;

pub fn entrada_estoque_db(conn_db:  &Connection, produto: &Produto) -> Result<()>{

    conn_db.execute( " 
        UPDATE estoque 
        SET quantidade_est = quantidade_est + ?1
        WHERE id_merc = ?2
        ",
        (&produto.quantidade_est, &produto.id_merc),
    )?;

    Ok(())

}

pub fn listagem_estoque_db(conn_db:  &Connection) -> Result<Vec<Produto>>{
    
    let mut stmt = conn_db.prepare(" SELECT * FROM estoque ")?;
    let produto_iter = stmt.query_map([], |row|{

    Ok(Produto{
        id_merc: row.get(0)?,
        nome_merc: row.get(1)?,
        quantidade_est: row.get(2)?,
    })
    })?; 

    let vec_produtos: Result<Vec<Produto>> = produto_iter.collect();

    vec_produtos
}

pub fn checagem_estoque(conn_db:  &Connection, unidades: &usize, nome_merc: &String) -> Result<bool>{

    let mut stmt = conn_db.prepare("
        SELECT quantidade_est - ?1 >= 0 
        FROM estoque
        WHERE nome_merc = ?2
    ")?;
    let resultado: bool = stmt.query_row(
        (unidades,nome_merc), 
        |row| row.get(0))?;
    Ok(resultado)
}

pub fn saida_estoque_db(conn_db:  &Connection, produto: &ItemPedido) -> Result<()>{

    conn_db.execute( " 
        UPDATE estoque 
        SET quantidade_est = quantidade_est - ?1
        WHERE nome_merc = ?2
        ",
        (&produto.quantidade, &produto.produto_nome),
    )?;

    Ok(())

}

pub fn incluir_item_estoque_db(conn_db:  &Connection, nome_merc: String, quantidade_est: usize) -> Result<()>{

    conn_db.execute("
        INSERT INTO estoque (nome_merc,quantidade_est)
        VALUES (?1,?2)
        ",(nome_merc,quantidade_est))?;

        Ok(())
}

pub fn excluir_item_estoque_db(conn_db: &Connection, item_id: usize) -> Result<()> {

    conn_db.execute(
        "DELETE FROM estoque
        WHERE id_merc = ?
        LIMIT 1",
        [item_id] 
    )?;

    Ok(())
}
