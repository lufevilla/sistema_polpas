use rusqlite::Connection;

use crate::error::AppError;

pub fn create_database() -> Result<Connection, AppError> {
    let conn_db = Connection::open("banco_de_dados.db")?;
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
            uf TEXT NOT NULL,
            data_registro TEXT DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS pedidos(
            id_pedidos INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL, 
            data TEXT DEFAULT CURRENT_TIMESTAMP,
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

        CREATE TABLE IF NOT EXISTS movimentacao_estoque (
            id_movimentacao INTEGER PRIMARY KEY AUTOINCREMENT,
            id_merc INTEGER NOT NULL,
            tipo_movimentacao TEXT NOT NULL,        
            quantidade INTEGER NOT NULL,             
            custo_unitario_compra REAL,
            custo_total_compra REAL,                 
            data_movimentacao TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (id_merc) REFERENCES estoque (id_merc) ON DELETE RESTRICT
        ); 


        
    ")?;

    let tem_coluna_nova: bool = conn_db.query_row(
        "SELECT COUNT(*) > 0 FROM pragma_table_info('movimentacao_estoque') WHERE name = 'custo_unitario_compra'",
        [],
        |row| row.get(0),
    )?;
    if !tem_coluna_nova {
        let tem_coluna_antiga: bool = conn_db.query_row(
            "SELECT COUNT(*) > 0 FROM pragma_table_info('movimentacao_estoque') WHERE name = 'custo_unitario'",
            [],
            |row| row.get(0),
        )?;
        if tem_coluna_antiga {
            conn_db.execute(
                "ALTER TABLE movimentacao_estoque RENAME COLUMN custo_unitario TO custo_unitario_compra",
                [],
            )?;
        }
    }

    Ok(conn_db)
}

pub fn obter_conexao() -> Result<Connection, AppError> {
    let conn = Connection::open("banco_de_dados.db")?;
    Ok(conn)
}
