#[derive(Default, Debug )]
pub struct Endereco {

    pub cep: String,
    pub logradouro: String,
    pub numero: String,
    pub complemento: Option<String>,
    pub bairro: String,
    pub municipio: String, 
    pub uf: String,

}

#[derive(Default, Debug)]
pub struct Cliente {
    pub id: usize,
    pub nome: String,
    pub cadastro: String,
    pub endereco: Endereco,
    pub telefone: String,
    //pub email: String,
    // Depois eu adiciono eles no crud de clientes 

}

