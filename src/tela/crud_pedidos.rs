// esse arquivo possui o servico de CRUD para os pedidos
use crate::models::pedido::{Pedido, ItemPedido};
use crate::tela::operacoes_basicas::*;
use crate::models::cliente::Cliente;


pub fn novo_pedido(vec_pedidos: &mut Vec<Pedido>,vec_clientes: &Vec<Cliente>){

    let mut soma: f64 = 0.0;
    loop {
        limpar();
        
        let mut pedido: Pedido =  Pedido::default();//criando o pedido 

        pedido.id =vec_pedidos.len()+1;//número de pedido

        println!("\
        Vamos Cadastrar um novo Pedido.\n\
        Para começar digite o id do cliente que realizou o Pedido:\n\
        ");
        pedido.cliente_id = leitura_dados();//referenciando qual foi o cliente que fez esse pedido
        println!("qual a data de realização do pedido?");
        pedido.data = leitura();
        loop {
            println!("quis dos itens a seguir você deseja adicionar ao pedido"); 
            pausar(2);
            limpar();
            soma += itens_pedidos(&mut pedido);
            print!("deseja adicionar mais algum intem a compra deste cliente?\n (sim/nao)");
            let opcao: String = leitura();
            if opcao.eq_ignore_ascii_case("nao"){
                break;
            }
        }
        pedido.valor_total = soma;
     
    }


}

fn itens_pedidos(pedido: &mut Pedido) -> f64 {

    let mut novo_item = ItemPedido::default();

    println!("\
        Abacaxi - R$30,00\n\
        Abacaxi c/ hortelã - R$30,00\n\
        Acerola - R$30,00\n\
        Caju- R$30,00\n\
        Detox- R$30,00\n\
        Frutas vermelhas - R$45,00\n\
        Goiaba - R$30,00\n\
        Laranja c/ Acerola - R$30,00\n\
        Manga - R$30,00\n\
        Maracujá - R$45,00\n\
        Melancia - R$30,00\n\
        Melão - R$30,00\n\
        Morango - R$30,00\n\
    ");
    loop {
        let opcao: String = leitura();
        match opcao.trim() {
            "Abacaxi" | "Abacaxi c/ hortelã" | "Acerola" | "Caju" | "Detox" | "Goiaba" | "Laranja c/ Acerola" | "Manga" | "Melancia" | "Melão" | "Morango" => {
                novo_item.valor = 30.00;
                novo_item.produto_nome = opcao;
                break;
            }
            "Frutas vermelhas" | "Maracujá" => {
                novo_item.valor = 45.00;
                novo_item.produto_nome = opcao;
                break;
            }
            _ => {println!("Opção inválida de produto!");}
        }
    }
    println!("qual a quantidade de {} desejada?", novo_item.produto_nome);
    novo_item.quantidade = leitura_dados();

    let valor_total_do_item = novo_item.valor * (novo_item.quantidade as f64);

    pedido.itens.push(novo_item);
    
    valor_total_do_item
    
}