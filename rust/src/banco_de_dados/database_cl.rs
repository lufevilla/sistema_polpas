use rusqlite::{Result, params};
use crate::error::AppError;
use crate::models::cliente::*;
use crate::create_db::obter_conexao;


// todas as funções serão praticamente identica com a unica diferença sendo a função do sqlite e suas clausulas presentes  em cada uma delas 

pub fn incluir_cliente_db( cliente: Cliente) -> Result<(), AppError> { 
        let conn_db = obter_conexao();
        conn_db?.execute(
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

pub fn atualizar_cliente_db( cliente: &Cliente, cliente_id: i64) -> Result<(), AppError> {
    
    let conn_db = obter_conexao()?;
    conn_db.execute(
        "UPDATE clientes
         SET nome = ?1, cadastro = ?2, cep = ?3, logradouro = ?4, 
             numero = ?5, complemento = ?6, bairro = ?7, municipio = ?8, uf = ?9 
         WHERE id = ?10",
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

pub fn excluir_cliente_db (cliente_id: i64) -> Result<(),AppError> {

    let conn_db = obter_conexao()?;
    conn_db.execute(
        "DELETE FROM clientes
        WHERE id = ?
        LIMIT 1",
        params![cliente_id] 
    )?;

    Ok(())
}


pub fn pesquisa_cliente_db(nome_cliente: &String, cadastro_cliente: &String) -> Result<bool, AppError>{

    let conn_db = obter_conexao()?;
    let existe: bool = conn_db.query_row(
        "SELECT EXISTS(SELECT 1 FROM usuarios WHERE nome = ?1 AND cadastro = ?2)",
        [nome_cliente,cadastro_cliente],

        |row| row.get(0),// o DB retorna um true ou false se ele achar algo
    )?;
    Ok(!existe)// como se espera que não tenha niguém com esses dados, o banco vai retornar um false("não existe niguém com esse valores aqui"), aí a fn que está chamando essa receberá um true, que é o oposto(para ser uma espécie de sinal verde pra prosseguir)

}

