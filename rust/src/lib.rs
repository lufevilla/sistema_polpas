pub mod api;
mod frb_generated;
pub mod models;
pub mod banco_de_dados;
pub mod error;


use crate::banco_de_dados::create_db; 
use crate::models::pedido::*;



#[tokio::main]
async fn main(){

    let mut vec_itens: Vec<ItemPedido>  = Vec::new();

    let mut conn_db = create_db::create_database();
            //match create_db::create_database(){
                // Ok(conexao) => conexao,
                // Err(erro) => {
                //     println!("Erro ao iniciar o banco: {}", erro);//sugestão de tratamento de erro na incialização do DB indicada pelo gemini 
                //     return;
                // }
            // };


    mostrar_menu(&mut vec_itens,&mut conn_db);

}
