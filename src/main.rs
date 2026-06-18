
mod models;
mod tela;

use tela::menu::mostrar_menu;
use models::cliente::Cliente;
use models::pedido::Pedido;


use crate::models::db_create;

fn main(){

    let mut vec_clientes: Vec<Cliente>  = Vec::new();
    let mut vec_pedidos: Vec<Pedido>  = Vec::new();
    
  let conn_db = match db_create::create_database() {
        Ok(conexao) => conexao,
        Err(erro) => {
            eprintln!("Erro ao iniciar o banco: {}", erro);//sugestão de tratamento de erro na incialização do DB indicada pelo gemini 
            return;
        }
    };

    mostrar_menu(&mut vec_clientes,&mut vec_pedidos,&conn_db);
    
}

//vou refazer o data base seguindo esse video aqui https://www.youtube.com/watch?v=ZswK3fiyQEE
// acho que tive problemas no save do DB pelo DB Browser 