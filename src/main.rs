mod models;
mod tela;

use tela::menu::mostrar_menu;
use models::cliente::Cliente;
use models::pedido::Pedido;

fn main(){
    let mut vec_clientes: Vec<Cliente> = Vec::new();
    let mut vec_pedidos: Vec<Pedido> = Vec::new();

    
    mostrar_menu(&mut vec_clientes, &mut vec_pedidos);
    
}