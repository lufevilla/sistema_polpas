
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
    
    let mut stmt = conn_db.prepare(" SELECT * FROM stock ")?;
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

pub fn checagem_estoque(conn_db:  &Connection, unidades: &usize, nome_merc: &String) -> Result<(bool)>{

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


// UPDATE nome_da_tabela 
// SET nome_da_coluna = 'novo_valor' 
// WHERE id = 1;
