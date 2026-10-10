use crate::banco_de_dados::relatorios_db::*;
use crate::error::AppError;

pub async fn movimentacao_mensal() -> Result<(f64,f64), AppError>{
    
    let gastos = soma_gastos_mercadorias_db()?;
    let bruto_vendas = bruto_vendas_mensal_db()?;
    Ok((gastos,bruto_vendas))
}

pub async fn saida_mensal() -> Result<Vec<(String,i64)>, AppError>  {
    let mut vec_produtos = saida_itens_mensais()?;
    vec_produtos.sort_unstable();
    Ok(vec_produtos)
}

pub async fn mov_registros_clientes() -> Result<(Vec<i64>, i64), AppError>{
    let novos_clientes = relatorio_cliente_mensal()?;
    let num_cl_novos = novos_clientes.len() as i64;
    Ok((novos_clientes, num_cl_novos))
}   