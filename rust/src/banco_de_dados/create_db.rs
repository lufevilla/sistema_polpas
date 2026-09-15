use rusqlite::{Connection, Result};

use crate::error::AppError;

pub fn create_database () -> Result<Connection, AppError> {

    let conn_db = Connection::open("banco_de_dados.db").unwrap();
    conn_db.execute_batch("
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
        );

        CREATE TABLE IF NOT EXISTS pedidos(
            id_pedidos INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL, 
            data TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            valor_total REAL NOT NULL,
            FOREIGN KEY (cliente_id) REFERENCES clientes(id) 
        );

        CREATE TABLE IF NOT EXISTS itens_pedido (
            id_item INTEGER PRIMARY KEY AUTOINCREMENT,
            pedido_id INTEGER NOT NULL,          
            produto_id INTEGER NOT NULL,
            quantidade INTEGER NOT NULL,
            valor REAL NOT NULL,
            subtotal REAL NOT NULL, 
            FOREIGN KEY (pedido_id) REFERENCES pedidos(id_pedidos) ON DELETE CASCADE
            FOREIGN KEY (produto_id) REFERENCES estoque(id_merc)
        );
            
        CREATE TABLE IF NOT EXISTS estoque(
            id_merc INTEGER PRIMARY KEY AUTOINCREMENT,
            nome_merc TEXT UNIQUE NOT NULL,
            quantidade_est INTEGER NOT NULL,
            quantidade_minima INTEGER NOT NULL,
            valor_unitario REAL NOT NULL
        );
        
    ").unwrap();

    Ok(conn_db)
}

pub fn obter_conexao() -> Result<Connection, AppError> {
    let conn = Connection::open("banco_de_dados.db")?;
    Ok(conn)
}
