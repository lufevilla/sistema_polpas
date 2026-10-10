use crate::error::AppError;
use crate::models::pedido::*;
use crate::banco_de_dados::database_est::*;

pub async fn incluir_item_estoque(produto: Produto) -> Result<(), AppError>{

    checagem_presenca_dados(&produto)?; 
    match pesquisa_mercadoria_db(&produto.nome_merc){
        Ok(true) => {
            return incluir_merc_est_db(produto);
        }
        Ok(false) => {
            return Err(AppError::MercadoriaJaExiste);
        }
        Err(e) =>{
            return Err(e);
        }
    }
    
}

pub async fn entrada_no_estoque (id_merc: i64, quantidade_a_adicionar: i64, valor_unitario_compra: f64) -> Result<(), AppError> {
    let mut movimentacao = Movimentacoes::default();
    movimentacao.id_merc = id_merc;
    movimentacao.quantidade = quantidade_a_adicionar;
    movimentacao.custo_unitario_compra = valor_unitario_compra;
    movimentacao.tipo_movimentacao = "ENTRADA".to_string();
    entrada_est_db(movimentacao)?;
    Ok(())
}

pub async fn listagem_do_estoque() -> Result<Vec<Produto>, AppError>{
    let vec_estoque = listagem_estoque_db()?;
    Ok(vec_estoque)
}

pub async fn saida_estoque(quantidade_saida: i64, id_merc: i64) -> Result<(),AppError>{

    saida_est_db(quantidade_saida, id_merc)?;
    Ok(())
}

pub async fn excluir_item(id_merc: i64) -> Result<(), AppError> {
    excluir_produto_est_db(id_merc)?;
    Ok(())
}

fn checagem_presenca_dados(produto: &Produto) -> Result<(), AppError>{
        let campos_obrigatorios = [
        ("Nome da Mercadoria".to_string(), produto.nome_merc.clone()),
        ("Quantidade Presente".to_string(),produto.quantidade_est.to_string()),
        ("Quantidade Minima de estoque".to_string(), produto.quantidade_minima.to_string()),
        ("Valor unitário do produto".to_string(), produto.valor_unitario.to_string()),
    ];
    if let Some((nome_campo, _)) = campos_obrigatorios.iter().find(|(_, val)| val.trim().is_empty()) {
        return Err(AppError::DadosNaoInseridos(nome_campo.to_string()));
    } else {
        return Ok(());
    }

}