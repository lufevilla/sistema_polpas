use rusqlite::Connection;

use crate::banco_de_dados::database_est::{checagem_estoque, saida_estoque_db};
use crate::banco_de_dados::database_pd::*;
// esse arquivo possui o servico de CRUD para os pedidos
use crate::models::pedido::{Pedido, ItemPedido};
use crate::cli::operacoes_basicas::*;

pub fn novo_pedido(vec_itens: &mut Vec<ItemPedido>,conn_db: &mut Connection){

    limpar();
    let mut pedido: Pedido =  Pedido::default();//criando o pedido 
     println!("ATENÇÃO!!\n por padrão do sistema a data cadastrada no pedido é a data de hoje");
    pausar(2);
    limpar();
    println!("\
        Vamos Cadastrar um novo Pedido.\n\
        Para começar digite o id do cliente que realizou o Pedido:
    ");
    pedido.cliente_id = leitura_dados();//referenciando qual foi o cliente que fez esse pedido
    println!("vamos adicionar os itens do pedido");
    pedido.valor_total = itens_pedidos(vec_itens,conn_db);
    println!("Você adicionou {} itens ao pedido\nTotal do pedido é de: {}", vec_itens.len(), pedido.valor_total);
    
    if let Ok( recebe_id_pedido) = incluir_pedido_db(conn_db, &pedido) {
        println!("Pedido registrado com sucesso!");
        insercao_de_itens_db(conn_db, vec_itens, recebe_id_pedido);

    } else {println!("falha ao registrar pedido no Banco de dados"); } //tá dando erro aqui 
    pausar(3);
    limpar();


}

fn itens_pedidos(vec_itens: &mut Vec<ItemPedido>, conn_db: &mut Connection) -> f64 {

    let mut total:f64 = 0.0; //retorno do valor total
    
    loop{
        limpar();
        let mut novo_item = ItemPedido::default();
        println!("\
            (1)Abacaxi - R$30,00\n\
            (2)Abacaxi c/ hortelã - R$30,00\n\
            (3)Acerola - R$30,00\n\
            (4)Caju- R$30,00\n\
            (5)Detox- R$30,00\n\
            (6)Frutas vermelhas - R$45,00\n\
            (7)Goiaba - R$30,00\n\
            (8)Laranja c/ Acerola - R$30,00\n\
            (9)Manga - R$30,00\n\
            (10)Maracujá - R$45,00\n\
            (11)Melancia - R$30,00\n\
            (12)Melão - R$30,00\n\
            (13)Morango - R$30,00\n");

        loop {
        let opcao = leitura().to_ascii_lowercase();
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

        println!("qual a quantidade desejada?");
        novo_item.quantidade = leitura_dados();//recebe a quantidade do item 
        let resultado = checagem_estoque(conn_db, &novo_item.quantidade, &novo_item.produto_nome);
        pausar(2);
        limpar();
        match resultado {
            Ok(true) =>{ 
                novo_item.subtotal = novo_item.valor * (novo_item.quantidade as f64); //calcula o subtotal do item    
                total += novo_item.subtotal;// soma do total do pedido
                if let Err((Error)) = saida_estoque_db(conn_db, &novo_item){ //após a checagem do estoque e da confirmação das informações do item subtrai-se a qauntidade desejada do estoque
                    println!("Erro ao atualizar a quantidade do estoque");
                }
                vec_itens.push(novo_item);//salva efetivamente o item no vetor 
                println!("Deseja adicionar mais algum item ? (Sim/nao)");
                let opcao: String = leitura();
                pausar(2);
                limpar();
                if opcao.trim().eq_ignore_ascii_case("nao"){
                    break;
                }
            }
            Ok(false) => {
                println!("Saldo insuficiente de estoque \nTente novamente");
                pausar(2);
                limpar();
            }
            _ => {println!("Erro ao consultar o estoque")}
        }
    }
    total
}

fn insercao_de_itens_db(conn_db: &Connection ,vec_itens: &mut Vec<ItemPedido>, id_pedido: usize){
    for item_pedido in vec_itens.iter(){// deve-se usar o iter() para somente leitura 
        if let Ok(()) = incluir_item_pedido_db(conn_db, item_pedido , &id_pedido)  {
            println!("item adicionado com sucesso!");
        }else { println!("Erro ao inserir item no banco de dados!");}
    }
    vec_itens.clear();// o vetor deve ser limpo completamente para isolar os itens de cada pedido 
}

pub fn listar_pedidos(conn_db: &Connection){

    limpar();
      println!("listagem de todos os pedidos...");
    pausar(2);
    limpar();
    println!("********** PEDIDOS REGISTRADOS **********");
    if let Ok(vec_pedidos_result) =  listar_pedidos_db(conn_db){
        for pedido in vec_pedidos_result {
            println!("
            Número do pedido: {}
            ID do cliente: {}
            Data: {}
            Valor total: {}",
            pedido.id,
            pedido.cliente_id,
            pedido.data,
            pedido.valor_total
            );
            for item in pedido.itens{
                println!("
            Item: {}
            Quantidade: {}
            Valor unitário: {}
            SUbtotal: {}",
            item.produto_nome,
            item.quantidade,
            item.valor,
            item.subtotal
            );
            }
            println!("******************************************");
        }
    }else { println!("não foi possivel listar os usuarios cadastrados no banco de dados...");}
    println!("\nDigite algo para continuar");
    leitura();
}

pub fn excluir_pedido(conn_db: &Connection){

    limpar();
    println!("insira o ID do pedido que deseja excluir");
    let pedido_id: usize = leitura_dados();
    println!("você tem certeza ???\n(Sim/nao)");
    let opcao: String = leitura();
    if opcao.trim().eq_ignore_ascii_case("sim"){
        limpar();
        println!("excluindo pedido...");
        let resultado  =  excluir_pedido_db(conn_db, pedido_id);
        if resultado == Ok(()){
                println!("Pedido excluido com sucesso!");
                pausar(2);
                return;
        }else{
                    println!("Não foi possivel excluir o pedido solicitado");
                pausar(2);
                return;
        }
    }else{ 
        limpar();
        println!("cancelando a exclusão...");
        pausar(2);
    }
}