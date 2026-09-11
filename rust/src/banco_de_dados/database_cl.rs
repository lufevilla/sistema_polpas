use rusqlite::{Connection, Result, params};
use crate::models::cliente::*;


// todas as funções serão praticamente identica com a unica diferença sendo a função do sqlite e suas clausulas presentes  em cada uma delas 

pub fn incluir_cliente_db(conn_db: &Connection, cliente: &Cliente) -> Result<()> { 
        conn_db.execute(
        "INSERT INTO clientes (nome, cadastro, telefone, cep, logradouro, numero, complemento, bairro, municipio, uf)
         VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)",
        (
            &cliente.nome, 
            &cliente.cadastro, 
            &cliente.telefone,
            &cliente.endereco.cep, 
            &cliente.endereco.logradouro, 
            &cliente.endereco.numero, 
            &cliente.endereco.complemento, // O rusqlite converte Option automáticamente, Some vira TEXT e None vira NULL
            &cliente.endereco.bairro, 
            &cliente.endereco.municipio, 
            &cliente.endereco.uf
        ),
    )?;

    Ok(())
}

pub fn selecao_cliente_db(conn_db: &Connection, cliente_id: usize) -> Result<Cliente>{

    let mut stmt = conn_db.prepare("SELECT * FROM clientes WHERE id = ?")?;
    let  cliente_selecionado = stmt.query_row([cliente_id], |row|{
        
        let endereco_cliente = Endereco {
            cep: row.get(4)?,
            logradouro: row.get(5)?,
            numero: row.get(6)?,
            complemento: row.get(7)?,
            bairro: row.get(8)?,
            municipio: row.get(9)?,
            uf: row.get(10)?,
        };


        Ok( Cliente {
            id: row.get(0)?,
            nome: row.get(1)?,
            cadastro: row.get(2)?,
            telefone: row.get(3)?,
            endereco: endereco_cliente,
        })
    }
    )?;
    
    Ok(cliente_selecionado)// toda vez que se usa o result, o retorno da fn deve estar 'embrulhada' dentro de um ok 

}

pub fn atualizar_cliente_db(conn_db: &Connection, cliente: &Cliente, cliente_id: usize) -> Result<()> {
    
    conn_db.execute(
        "UPDATE clientes
         SET nome = ?1, cadastro = ?2, cep = ?3, logradouro = ?4, 
             numero = ?5, complemento = ?6, bairro = ?7, municipio = ?8, uf = ?9 
         WHERE id = ?10",//where é uma clausula que age como um filtro, selecionando somente o cliente desejado 
                         //se essa clausula não estiver presente o sqlite irá alterar todas as linhas do DB 
        (
            &cliente.nome,
            &cliente.cadastro,
            &cliente.endereco.cep,
            &cliente.endereco.logradouro,
            &cliente.endereco.numero,
            &cliente.endereco.complemento,
            &cliente.endereco.bairro,
            &cliente.endereco.municipio,
            &cliente.endereco.uf,
            cliente_id,
        ),
    )?; // O '?' devolve o erro para quem chamou a função e evita que o código quebre se houver algum erro no registro do DB 

    Ok(())//retorno de result 
}

pub fn listar_cliente_db(conn_db: &Connection) -> Result<Vec<Cliente>> {

    let mut stmt = conn_db.prepare("SELECT *FROM clientes ")?;
    let clientes_iter = stmt.query_map([], |row| {

        let endereco_cliente = Endereco {
            cep: row.get(4)?,
            logradouro: row.get(5)?,
            numero: row.get(6)?,
            complemento: row.get(7)?,
            bairro: row.get(8)?,
            municipio: row.get(9)?,
            uf: row.get(10)?,
        };


        Ok( Cliente {
            id: row.get(0)?,
            nome: row.get(1)?,
            cadastro: row.get(2)?,
            telefone: row.get(3)?,
            endereco: endereco_cliente,
        })
    })?;
    let vec_clientes_result: Result<Vec<Cliente>> = clientes_iter.collect();

    vec_clientes_result
}

pub fn excluir_cliente_db(conn_db: &Connection, cliente_id: usize) -> Result<()> {

    conn_db.execute(
        "DELETE FROM clientes
        WHERE id = ?
        LIMIT 1",
        params![cliente_id] 
    )?;

    Ok(())
}