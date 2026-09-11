use rusqlite::{Connection, Result};

pub fn create_database () -> Result<Connection> {

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
            produto_nome TEXT NOT NULL,
            quantidade INTEGER NOT NULL,
            valor REAL NOT NULL,
            subtotal REAL NOT NULL, 
            FOREIGN KEY (pedido_id) REFERENCES pedidos(id_pedidos) ON DELETE CASCADE -- esta função serve para deletar todos os itens do DB,caso o pedido seja excluido 
        );
            
        CREATE TABLE IF NOT EXISTS estoque(
            id_merc INTEGER PRIMARY KEY AUTOINCREMENT,
            nome_merc TEXT UNIQUE NOT NULL,
            quantidade_est INTEGER NOT NULL
        );
        
    ").unwrap();

    Ok(conn_db)
}