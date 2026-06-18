use rusqlite::Connection;

use crate::models::cliente::Cliente;
use crate::models::pedido::Pedido;


use crate::tela::operacoes_basicas::*;
use crate::tela::servico_cliente::*;
use crate::tela::crud_pedidos::*;




use super::operacoes_basicas::limpar;


pub fn mostrar_menu(vec_clientes: &mut Vec<Cliente>,vec_pedidos: &mut Vec<Pedido>,conn_db: &Connection) {
    loop {
        limpar();
        println!("\
            ********** MENU **********\n\
            Escolha uma das opções abaixo:\n\
            1 - Seção de Clientes\n\
            2 - Seção de Pedidos\n\
            3 - Estoque\n\
            4 - Relatórios\n\
            0 - Finalizar o Programa\n\
        ");

        let opcao: usize = leitura_dados();
        
        limpar();

        match opcao{
            1 => crud_cliente(vec_clientes,conn_db),
            2 => crud_pedidos_menu(vec_pedidos,vec_clientes, conn_db),
            3 => println!("3"),
            4 => println!("4"),
            0 => {  
                    println!("Finalizando o programa..."); 
                    pausar(2);
                    limpar();
                    return;
                },
            _ => println!("opcao invalida")
        } 
        println!("\naguarde...");
        pausar(3);
    }


}

fn crud_cliente(vec_clientes: &mut Vec<Cliente>, conn_db: &Connection){

    loop {
        limpar();
        println!("\
            ********** MENU **********\n\
            Escolha uma das opções abaixo:\n\
            1 - Cadastrar novo cliente\n\
            2 - Alterar cliente\n\
            3 - Listar clientes cadastrados\n\
            4 - exluir clientes\n\
            0 - Voltar para o menu anterior\n\
        ");

        let opcao: usize = leitura_dados();
        
        limpar();

        match opcao{
            1 => incluir_cliente(conn_db),
            2 => alterar_cliente(conn_db),
            3 => listar_clientes(conn_db),
            4 => excluir_cliente(conn_db),
            0 => {  
                    println!("voltando para o menu anterior"); 
                    return;
                },
            _ => println!("opcao invalida")
        } 
        println!("\naguarde...");
        pausar(3);
        
    }

}

fn crud_pedidos_menu(vec_pedidos: &mut Vec<Pedido>, vec_clientes: &mut Vec<Cliente>, conn_db: &Connection) {

      
    loop{
        limpar();
        println!("\
            ********** MENU **********\n\
            Escolha uma das opções abaixo:\n\
            1 - Registrar Novo Pedido\n\
            2 - Alterar/Atualizar Pedido\n\
            3 - Listar Pedidos\n\
            4 - Excluir Pedidos\n\
            0 - Voltar para o menu anterior\n\
        ");

        let opcao: usize = leitura_dados();
        
        limpar();

        match opcao{
            1 => novo_pedido(vec_pedidos, vec_clientes, conn_db),
            2 => println!("2"),
            3 => listar_pedidos(vec_pedidos, conn_db),
            4 => println!("4"),
            0 => {  
                    println!("Voltando para o menu anterior"); 
                    return;
                },
            _ => println!("opcao invalida")
        } 
        println!("\naguarde...");
        pausar(3);
    }

}