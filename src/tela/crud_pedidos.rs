use rusqlite::Connection;

// esse arquivo possui o servico de CRUD para os pedidos
use crate::models::pedido::{Pedido, ItemPedido};
use crate::tela::operacoes_basicas::*;
use crate::models::cliente::Cliente;


pub fn novo_pedido(vec_pedidos: &mut Vec<Pedido>,vec_clientes: &Vec<Cliente>,conn_db: &Connection){

    let mut soma: f64 = 0.0;
    
        limpar();
        
        let mut pedido: Pedido =  Pedido::default();//criando o pedido 

        pedido.id =vec_pedidos.len()+1;//número de pedido

        println!("\
        Vamos Cadastrar um novo Pedido.\n\
        Para começar digite o id do cliente que realizou o Pedido:\n\
        ");
        pedido.cliente_id = leitura_dados();//referenciando qual foi o cliente que fez esse pedido
        println!("qual a data de realização do pedido?");
        pedido.data = leitura();//data do pedido 
        loop { //loop para cada item que deve ser adicionado ao vetor 
            println!("quis dos itens a seguir você deseja adicionar ao pedido"); 
            pausar(2);
            soma += itens_pedidos(&mut pedido); // essa função retorna o subtotal de cada item que foi pedido e a variavel 'soma' soma todos os subtotais
            print!("deseja adicionar mais algum intem a compra deste cliente?\n (sim/nao)");
            let opcao: String = leitura(); //opção para quebrar o loop 
            if opcao.eq_ignore_ascii_case("nao"){
                break;
            }
        }
        pedido.valor_total = soma;
        vec_pedidos.push(pedido);// insere definitivamente o conjunto de informações no vetor de pedidos 
        println!("Pedido registrado com sucesso!!");    
    


}

fn itens_pedidos(pedido: &mut Pedido) -> f64 {

    limpar();
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
        let opcao: String = leitura().to_ascii_lowercase();
        match opcao.trim() {
            "abacaxi" | "abacaxi c/ hortelã" | "acerola" | "caju" | "detox" | "goiaba" | "laranja c/ acerola" | "manga" | "melancia" | "melão" | "morango" => {
                novo_item.valor = 30.00;
                novo_item.produto_nome = opcao;
                break;
            }
            "frutas vermelhas" | "maracujá" => {
                novo_item.valor = 45.00;// recebe o valor unitário do produto 
                novo_item.produto_nome = opcao;
                break;
            }
            _ => {println!("Opção inválida de produto!");}
        }
    }
    println!("qual a quantidade de {} desejada?", novo_item.produto_nome);
    novo_item.quantidade = leitura_dados();//recebe a quantidade do item 
    limpar();
    let valor_total_do_item = novo_item.valor * (novo_item.quantidade as f64); //calcula o subtotal do item    
    novo_item.valor= valor_total_do_item;//descarta o valor unitário para receber o valor do subtotal 
    pedido.itens.push(novo_item);//salva efetivamente o item no vetor 

    valor_total_do_item//retorna o subtotal do item 
    
}

pub fn listar_pedidos(vec_pedidos: &mut Vec<Pedido>, conn_db: &Connection){

    limpar();
    if vec_pedidos.len() == 0 {
        println!("não existem pedidos cadastrados");
        pausar(3);
        return;
    } 
    println!("Deseja listar todos os pedidos ou somente um? \n(Todos/um ) ");
    let opcao: String = leitura().trim().to_lowercase();
    if opcao == "todos"{
        println!("********** LISTAGEM **********");
        for id in &mut *vec_pedidos {
            mostrar_pedidos(id );//a cada repetição do for ele anda um indice no vetor de pedidos e passa o pedido para que a função possa printar 
            println!("******************************"); 
        }
        println!("Digite algo para continuar");
        leitura();
    }else{
        println!("Digite o ID do pedido que deseja visualizar");
        let id: usize = leitura_dados();
        if let Some(pedido_encontrado) = vec_pedidos.iter_mut().find(|c| c.id == id) {
            mostrar_pedidos(pedido_encontrado);
            println!("Digite algo para continuar");
            leitura();
        }else {
            println!("Pedido com o ID {} não foi encontrado.", id);
            pausar(3);
        }
    }
     
}

fn mostrar_pedidos(pedido: &mut Pedido){

    println!("\
        ID do cliente: {}\n\
        Data: {}\n\
        Total: {}\n\
    ",pedido.cliente_id,pedido.data,pedido.valor_total);
    println!("Itens pedidos:");
    for itens in &pedido.itens{
           println!("#{} - {} un. - subtotal: {}",itens.produto_nome, itens.quantidade, itens.valor);
        }

}