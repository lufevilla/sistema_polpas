use crate::models::cliente::Cliente;
use crate::tela::operacoes_basicas::*;//crates vai pela origem




pub fn incluir_cliente (vec_clientes: &mut Vec<Cliente>){
    loop{

        limpar();

        let mut cliente: Cliente = Cliente::default();

        cliente.id = vec_clientes.len() + 1; // a cada novo cliente cadastrado ele soma 1 ao id 
        println!("Digite o nome do cliente");
        cliente.nome = leitura();

        println!("Digite o cpf do cliente (sem caracteres especiais) ");
        cliente.cadastro = leitura();

        println!("Campo de endereco\nCEP:");
        cliente.endereco.cep = leitura();

        println!("Logradouro (Rua/Av):");
        cliente.endereco.logradouro = leitura();
        
        println!("Número:");
        cliente.endereco.numero = leitura();
        
        //sugestão do Gemini para um campo onde pode não haver resposta
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

            vec_clientes.push(cliente);
            println!("cliente cadastrado com sucesso!");
            break; 
        
        }
    }
}

pub fn listar_clientes(vec_clientes: &mut Vec<Cliente>){

    limpar();
    if vec_clientes.len() == 0 {
        println!("não existem clientes cadastrados");
        pausar(3);
        return;
    } 
    
    println!("********** LISTAGEM **********");
    for id in &mut *vec_clientes {
        mostrar_cliente(id);
        println!("******************************"); 
    }
     


}

fn mostrar_cliente(cliente: &mut Cliente){

    println!("\
        ID: {}\n\
        nome: {}\n\
        CPF: {}\n\
    ",cliente.id,cliente.nome,cliente.cadastro);
    println!("Dados de endereço:");
    mostrar_endereco(cliente);

}

pub fn alterar_cliente (vec_clientes: &mut Vec<Cliente>){

    limpar();

     if vec_clientes.len() == 0 {
        println!("Não existem clientes cadastrados");
        pausar(3);
        return;
    } 

    println!("Digite o id do cliente que você deseja alterar");
    let id: usize = leitura_dados();

    //ajuda do gemini 
   if let Some(cliente_encontrado) = vec_clientes.iter_mut().find(|c| c.id == id) {
        entrada_dados(cliente_encontrado);
    } else {
        println!("Cliente com o ID {} não foi encontrado.", id);
        pausar(3);
    }
    //estava tentando usar o id diretamente na fn entrada_dados mas ocorria um problema 

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
        let deseja_continuar = leitura();
        if deseja_continuar.eq_ignore_ascii_case("nao") {
            println!("Alterações de endereço salvas com sucesso!");
            pausar(2);
            break; 
        }
    }
}

pub fn excluir_cliente(vec_cliente: &mut Vec<Cliente>) {

    limpar();

    if vec_cliente.len() == 0 {
        println!("não existem clientes cadastrados");
        pausar(3);
        return;
    }

    println!("Digite o id do cliente que você deseja excluir");
    let id: usize = leitura_dados();

   if let Some(cliente_encontrado) = vec_cliente.iter().find(|c| c.id == id) {
        println!("você tem certeza que deseja exluir permanentemente o cliente {}? (Sim/nao)", cliente_encontrado.nome);
        
        let opcao = leitura();
        if opcao.eq_ignore_ascii_case("sim") {
            println!("excluindo...");
            //sugestão do gemini 
            vec_cliente.retain(|c| c.id != id);
            //segundo ele usando o retain manten-se apenas o que possuir o id d iferente do listado
        }else{
            println!("cancelando...");
        }
    }else{
        println!("Cliente com o ID {} não foi encontrado.", id);
        pausar(3);
    }

    



}

pub fn mostrar_endereco(cliente: &Cliente) {
    println!(
        "CEP: {}\n\
        logrdouro: {}\n\
        numero: {}\n\
        complemento: {}\n\
        bairro: {}\n\
        municipio: {}\n\
        uf: {}\n",
        cliente.endereco.cep,
        cliente.endereco.logradouro, // Mantive com o nome do seu campo (sem o 'a')
        cliente.endereco.numero,
        cliente.endereco.complemento.as_deref().unwrap_or("Não informado"),
        cliente.endereco.bairro,
        cliente.endereco.municipio,
        cliente.endereco.uf
    );
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
        let deseja_continuar = leitura();
        if deseja_continuar.eq_ignore_ascii_case("nao") {
            println!("Alterações de endereço salvas com sucesso!");
            pausar(2);
            break; 
        }
    }
}