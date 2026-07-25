//esse arquivo possui o seviço de CRUD para os clientes 
use rusqlite::{Connection};

use crate::models::cliente::Cliente;
use crate::banco_de_dados::database_cl::*;
use crate::cli::operacoes_basicas::*;//crates vai pela origem

pub fn incluir_cliente (conn_db: &Connection){
    loop{

        limpar();

        let mut cliente: Cliente = Cliente::default();
        //cliente.id = vec_clientes.len() + 1; // não peciso mais disso pois o sqlite cuida da classificação do ID automaticamente para cada cliente  
        println!("Digite o nome do cliente");
        cliente.nome = leitura();

        println!("Digite o CPF/CNPJ do cliente (sem caracteres especiais) ");
        cliente.cadastro = leitura();

        println!("Insira o Telefone do cliente (também sem caracteres especiais)");
        cliente.telefone  = leitura();

        println!("Campo de endereco\nCEP:");
        cliente.endereco.cep = leitura();

        println!("Logradouro (Rua/Av):");
        cliente.endereco.logradouro = leitura();

        println!("Número:");
        cliente.endereco.numero = leitura();
           //sugestão do Gemini para um campo onde pode não haver resposta{
        println!("Complemento (Pressione Enter se não houver):");

        // Se a string NÃO estiver vazia, vira Some(entrada), se estiver vazia, vira None
        cliente.endereco.complemento = Some(leitura()).filter(|s| !s.trim().is_empty());

         println!("Bairro:");
        cliente.endereco.bairro = leitura();

        println!("Município:");
        cliente.endereco.municipio = leitura();

        println!("UF (Ex: SP):");
        cliente.endereco.uf = leitura();

        println!("os dados estão corretos? (Sim/nao)");
        let opcao: String = leitura();
        if opcao.eq_ignore_ascii_case("sim") {
            let resultado = incluir_cliente_db(conn_db, &cliente);
            if resultado == Ok(()) {
                println!("cliente cadastrado com sucesso!");
                break; 
            }else { 
                println!("Erro ao gravar cliente no Banco de Dados")
            }
        }
    }
}

pub fn listar_clientes(conn_db: &Connection){

    limpar();
      println!("listagem de todos os clientes...");
    pausar(2);
    limpar();
    println!("********** CLIENTES CADASTRADOS **********");
    if let Ok(vec_cliente_result) =  listar_cliente_db(conn_db){
        for cliente in vec_cliente_result {
            println!("
            ID: {}
            Nome: {}
            Cadastro: {}
            Telefone: {}
            ---Endereco---
            CEP: {}
            Logradouro: {}
            Numero: {}
            Complemento: {:?}
            Bairro: {}
            Município: {}
            UF {}",
            cliente.id,
            cliente.nome,
            cliente.cadastro,
            cliente.telefone,
            cliente.endereco.cep,
            cliente.endereco.logradouro,
            cliente.endereco.numero,
            cliente.endereco.complemento,
            cliente.endereco.bairro,
            cliente.endereco.municipio,
            cliente.endereco.uf
            );
            println!("******************************************");
        }
    }else { println!("não foi possivel listar os usuarios cadastrados no banco de dados...");}
    println!("\nDigite algo para continuar");
    leitura();
}

pub fn alterar_cliente (conn_db: &Connection){

    limpar();
    println!("insira o ID do cliente que deseja ataulizar");
    let cliente_id : usize = leitura_dados();
    
    if let Ok(mut cliente)  = selecao_cliente_db(conn_db, cliente_id){
        entrada_dados(&mut cliente);
        if let Ok(()) = atualizar_cliente_db(conn_db, &cliente, cliente_id){
            println!("cliente alterado com sucesso!");
            pausar(2);
            return; 
        }else{
            println!("falha ao atualizar cliente no banco de dados");
            pausar(2);
            return;
        }
    }else{println!("falha ao selecionar o cliente no database")}
}


fn entrada_dados(cliente: &mut Cliente){

    loop {
        limpar();
        println!("\
        quis parametros deseja mudar?\n\
        -Nome-\n\
        -CPF-\n\
        -Endereco-\n\
        ");

        let mut opcao: String = leitura();
        opcao = opcao.to_ascii_lowercase();
        pausar(2);
        limpar();
        match opcao.as_str() {

            "nome" => {
                println!("digite o novo nome do usuario");
                cliente.nome= leitura();
            }

            "cpf" => {
                println!("digite o novo cpf do usuario");
                cliente.cadastro = leitura();

            }
            "endereco" => {
                alterar_endereco(cliente);
            }
            _ => {
                println!("opção invalida...");
                pausar(2);
                continue;
            }


        }
         println!("Deseja alterar mais alguma informação do cliente? (Sim/nao)");
         let opcao = leitura();
        if opcao.eq_ignore_ascii_case("nao") {
            println!("Alterações de endereço salvas com sucesso!");
            pausar(2);
            break; 
        }
    }
}

pub fn excluir_cliente(conn_db: &Connection) {

    limpar();
    println!("insira o ID do cliente que deseja excluir");
    let cliente_id: usize = leitura_dados();
    println!("você tem certeza ???\n(Sim/nao)");
    let opcao: String = leitura();
    if opcao.trim().eq_ignore_ascii_case("sim"){
        limpar();
        println!("excluindo cliente...");
        let resultado  =  excluir_cliente_db(conn_db, cliente_id);
        if resultado == Ok(()){
                println!("Cliente excluido com sucesso!");
                pausar(2);
                return;
        }else{
                    println!("Não foi possivel excluir o cliente solicitado");
                pausar(2);
                return;
        }
    }else{ 
        limpar();
        println!("cancelando a exclusão...");
        pausar(2);
    }
}


fn alterar_endereco(cliente: &mut Cliente) {
    loop {
        limpar();
        println!(
            "Qual parâmetro do endereço deseja mudar?\n\
            - CEP -\n\
            - Logradouro -\n\
            - Numero -\n\
            - Complemento -\n\
            - Bairro -\n\
            - Municipio -\n\
            - UF -\n"
        );

        let mut opcao: String = leitura();
        opcao = opcao.trim().to_ascii_lowercase();
        pausar(2);
        limpar();

        match opcao.as_str() {
            "cep" => {

                println!("Digite o novo CEP:");
                cliente.endereco.cep = leitura();
            }
            "logradouro" => {
                println!("Digite o novo Logradouro (Rua/Av):");
                cliente.endereco.logradouro = leitura();
            }
            "numero" => {
                println!("Digite o novo número:");
                cliente.endereco.numero = leitura();
            }
            "complemento" => {
                println!("Digite o novo Complemento (Pressione Enter para remover/deixar vazio):");
                let entrada = leitura();
                cliente.endereco.complemento = Some(entrada).filter(|s| !s.trim().is_empty());
            }
            "bairro" => {
                println!("Digite o novo Bairro:");
                cliente.endereco.bairro = leitura();
            }
            "municipio" => {
                println!("Digite o novo Município:");
                cliente.endereco.municipio = leitura();
            }
            "uf" => {
                println!("Digite a nova UF (Ex: SP):");
                cliente.endereco.uf = leitura();
            }
            _ => {
                println!("Opção inválida...");
                pausar(2);
                continue; 
            }

        }

        println!("Deseja alterar mais alguma informação do endereço? (Sim/nao)");
              println!("Alterações de endereço salvas com sucesso!");
            pausar(2);
            break; 
        }
    }