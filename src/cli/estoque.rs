use rusqlite::Connection;
use crate::cli::operacoes_basicas::*;

use crate::models::pedido::*;
use crate::banco_de_dados::db_estoque::*;

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

pub fn incluir_item(conn_db: &Connection){

    loop {
        limpar();
        println!("Insira o nome do item que deseja adicionar");
        let nome_merc = leitura();
        println!("Agora adicione a quantidade incial do produto no estoque");
        let quantidade_est = leitura_dados();
        println!("As informações estão corretas??\n (Sim/nao)");
        let opcao: String = leitura();
        if opcao.trim().eq_ignore_ascii_case("sim"){
            if let Ok(()) = incluir_item_estoque_db(conn_db,nome_merc, quantidade_est){
                println!("Novo item cadastrado com sucesso!");
                break;
            }
        }else{
            println!("reiniciando...");
            pausar(2);
        }

    }
    
}

pub fn excluir_item(conn_db: &Connection) {

    limpar();
    println!("insira o ID do item que deseja excluir");
    let item_id: usize = leitura_dados();
    println!("você tem certeza ???\n(Sim/nao)");
    let opcao: String = leitura();
    if opcao.trim().eq_ignore_ascii_case("sim"){
        limpar();
        println!("excluindo item...");
        if let Ok(()) = excluir_item_estoque_db(conn_db, item_id){
                println!("Item excluido com sucesso!");
                pausar(2);
                return;
        }else{
                    println!("Não foi possivel excluir o item solicitado");
                pausar(2);
                return;
        }
    }else{ 
        limpar();
        println!("cancelando a exclusão...");
        pausar(2);
    }
}
