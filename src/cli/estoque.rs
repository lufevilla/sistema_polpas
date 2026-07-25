use rusqlite::Connection;
use crate::cli::operacoes_basicas::*;

use crate::models::pedido::*;
use crate::banco_de_dados::database_est::*;

pub fn entrada_no_estoque (conn_db: &Connection) {

    let mut produto: Produto = Produto::default();

    limpar();
    println!("Vamos registrar a entrada de mercadorias no estoque \nPrimeiro digite o id do item");
    produto.id_merc = leitura_dados();
    println!("Agora insira a quantidade que deseja adicionar ao estoque atual");
    produto.quantidade_est = leitura_dados();
    
    if let Ok(()) = entrada_estoque_db(conn_db, &produto){
        println!("Estoque ataulizado com sucesso");
    } else {
        println!("Erro ao atualizar o Estoque");
    }

}

pub fn listagem_do_estoque(conn_db: &Connection) {

    limpar();
    println!("**** Estoque ****");
    if let Ok(vec_produto ) = listagem_estoque_db(conn_db) {
        for produto in vec_produto.iter() {
            println!("id: {} | produto: {} | quantidade: {}",
                    produto.id_merc ,produto.nome_merc ,produto.quantidade_est);
        }
    }else {
        println!("Erro ao consultar o Estoque no banco de dados");
    }
}

