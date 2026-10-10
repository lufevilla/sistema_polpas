use rusqlite::{Result};
use crate::{banco_de_dados::create_db::obter_conexao, error::AppError};

pub fn soma_gastos_mercadorias_db() -> Result<f64,AppError> {
    let conn_db = obter_conexao()?; 
    let mut stmt = conn_db.prepare("       
        SELECT SUM(custo_total_compra) FROM movimentacao_estoque
        WHERE data_movimentacao  >=  date('now', '-30 days');
    ")?;
    let gasto_mensal: f64   =  stmt.query_row([], |row | {
        let opt_gasto_mensal: Option<f64> = row.get(0)?;
        Ok(opt_gasto_mensal.unwrap_or(0.0)) 
    })?;
    Ok(gasto_mensal)
}

pub fn bruto_vendas_mensal_db() -> Result<f64,AppError> {
    
    let conn_db = obter_conexao()?; 
    let mut stmt = conn_db.prepare("
        SELECT SUM(valor_total) FROM pedidos
        WHERE data >=  date('now', '-30 days');
    ")?;
    let valor_bruto = stmt.query_row([], |row|{
        let opt_valor_bruto: Option<f64> = row.get(0)?;
        Ok(opt_valor_bruto.unwrap_or(0.0))
    })?;

    Ok(valor_bruto)
}

pub fn saida_itens_mensais() -> Result<Vec<(String,i64)>,AppError> {
    
    let conn_db = obter_conexao()?;
    // essa query faz a junção das três tabelas e seleciona apenas o nome do produto e a quantidade total de itens que foram vendidos nos ultimos 30 dias 
    let mut stmt = conn_db.prepare(" 
        SELECT 
            estoque.nome_merc AS produto,
            SUM(itens_pedido.quantidade) AS total_saidas
        FROM itens_pedido
        INNER JOIN pedidos 
            ON itens_pedido.pedido_id = pedidos.id_pedidos
        INNER JOIN estoque  
            ON itens_pedido.produto_id = estoque.id_merc
        WHERE pedidos.data >= date('now', '-30 days')
        GROUP BY estoque.id_merc, estoque.nome_merc;
    ")?;
    let produtos = stmt.query_map([], |row| {
        Ok((
            row.get::<usize, String>(0)?,
            row.get::<usize,i64>(1)?
        ))
    })?;

    let mut vec_saida_produtos = Vec::new();
    for produto in produtos{
        vec_saida_produtos.push(produto?); 
    }
 
    Ok(vec_saida_produtos)
}

pub fn relatorio_cliente_mensal() -> Result<Vec<i64>, AppError> {
    let conn_db = obter_conexao()?;
    let mut stmt = conn_db.prepare("
        SELECT id FROM clientes
        WHERE data_registro >= date('now', '-30 days');
    ",)?;

    let novos_clientes: Vec<i64> = stmt.query_map([], |row| 
        row.get(0)
    )?.collect::<Result<Vec<i64>, _>>().map_err(AppError::from)?; // o map err foi uma sugestão de solução de erro do gemini 
    Ok(novos_clientes)
}