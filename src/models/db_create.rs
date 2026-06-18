use rusqlite::{Connection, Result};

pub fn create_database () -> Result<Connection> {

    let conn_db = Connection::open("banco_de_dados.db").unwrap();
    conn_db.execute("
        CREATE TABLE IF NOT EXISTS clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            cadastro TEXT UNIQUE NOT NULL,
            telefone TEXT NOT NULL,
            cep TEXT NOT NULL,
            logradouro TEXT NOT NULL,
            numero TEXT NOT NULL,
            complemento TEXT,
            bairro TEXT NOT NULL,
            municipio TEXT NOT NULL, 
            uf TEXT NOT NULL
            
        )
    ",()).unwrap();

    Ok(conn_db)
}