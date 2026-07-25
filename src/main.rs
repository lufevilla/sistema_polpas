pub mod models;
pub mod cli;
pub mod banco_de_dados;

use cli::menu::mostrar_menu;


use crate::banco_de_dados::create_db; 
use crate::models::pedido::*;

fn main(){

    let mut vec_itens: Vec<ItemPedido>  = Vec::new();

    let mut conn_db = match create_db::create_database() {
            Ok(conexao) => conexao,
            Err(erro) => {
                eprintln!("Erro ao iniciar o banco: {}", erro);//sugestão de tratamento de erro na incialização do DB indicada pelo gemini 
                return;
            }
        };

    mostrar_menu(&mut vec_itens,&mut conn_db);

}
