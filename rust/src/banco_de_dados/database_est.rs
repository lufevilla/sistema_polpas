
use rusqlite::{Result, params};
use crate::{banco_de_dados::create_db::obter_conexao, error::AppError, models::pedido::*};

pub fn incluir_merc_est_db(produto: Produto) -> Result<(), AppError>{
    
    let conn_db = obter_conexao()?;
    conn_db.execute("
    INSERT INTO estoque (nome_merc, quantidade_est, quantidade_minima, valor_unitario)
    VALUES (?1,?2,?3,?4)
    ", (
        produto.nome_merc,
        produto.quantidade_est,
        produto.quantidade_minima,
        produto.valor_unitario
        ),
    )?;
    Ok(())
}

pub fn entrada_est_db(id_merc: i64, quantidade_a_adicionar: i64) -> Result<(),AppError>{
    let conn_db = obter_conexao()?;
    conn_db.execute( " 
        UPDATE estoque 
        SET quantidade_est = quantidade_est + ?1
        WHERE id_merc = ?2
        ",
        (quantidade_a_adicionar, id_merc),
    )?;

    Ok(())

}

pub fn saida_est_db(quantidade_saida: i64, id_merc: i64) -> Result<(), AppError>{

    let conn_db = obter_conexao()?;
    let mut stmt = conn_db.prepare("
        SELECT quantidade_est - ?1 >= 0 
        FROM estoque
        WHERE nome_merc = ?2
    ")?;
    let resultado: bool = stmt.query_row(
        (quantidade_saida,id_merc), 
        |row| row.get(0))?;
    if resultado == true {
        conn_db.execute( " 
            UPDATE estoque 
            SET quantidade_est = quantidade_est - ?1
            WHERE id_merc = ?2
            ",
            (quantidade_saida, id_merc),
        )?;

        return Ok(());

    } else {
        return Err(AppError::EstoqueInsuficiente);
    }
}

pub fn ataulizar_produto_est_db(produto: &Produto) -> Result<(), AppError>{

    let conn_db = obter_conexao()?;
    conn_db.execute("
     UPDATE estoque
     SET nome_merc = ?1, quantidade_est = ?2, quantidade_minima = ?3, valor_unitario = ?4
     WHERE id_merc = ?5",
    (produto.nome_merc.clone(), produto.quantidade_est, produto.quantidade_minima, produto.valor_unitario, produto.id_merc),)?; // não entendi o porque do clone, mas o rust analyzer pediu 
    Ok(())

}


pub fn excluir_produto_est_db(id_merc: i64) -> Result<(),AppError>{
    
    let conn_db = obter_conexao()?;
    conn_db.execute("
    DELETE FROM estoque
    WHERE id_merc = ?
    LIMIT 1",
    params![id_merc]);

    Ok(())
}

pub fn pesquisa_mercadoria_db(nome_merc: &String) -> Result<bool, AppError> {

    let conn_db = obter_conexao()?;
    let result: bool = conn_db.query_row("
    SELECT EXISTS(SELECT 1 FROM estoque WHERE nome_merc = ?1)
    ", [nome_merc],
    |row | row.get(0),
    )?; 
    Ok(!result)
}

    pub fn listagem_estoque_db() -> Result<Vec<Produto>, AppError>{
        let conn_db = obter_conexao()?;
        let mut stmt = conn_db.prepare(" SELECT * FROM estoque ")?;
        let produto_iter = stmt.query_map([], |row| {
            Ok(Produto {
                id_merc: row.get(0)?,
                nome_merc: row.get(1)?,
                quantidade_est: row.get(2)?,
                quantidade_minima: row.get(3)?,
                valor_unitario: row.get(4)?,
            })
        })?;

        let produtos = produto_iter.collect::<Result<Vec<_>,_>>()?; 
        Ok(produtos)
    }

// id_merc INTEGER PRIMARY KEY AUTOINCREMENT,
// nome_merc TEXT UNIQUE NOT NULL,
// quantidade_est INTEGER NOT NULL,
// quantidade_minima INTEGER NOT NULL,
// valor_unitario REAL NOT NULL
