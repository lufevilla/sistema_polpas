// Adicionar uma implementação(métodos de struct) para a verificação das informações que serão inseridas 

#[derive(Default)]
pub struct Endereco {

    pub cep: String,
    pub logradouro: String,
    pub numero: String,
    pub complemento: Option<String>,
    pub bairro: String,
    pub municipio: String, 
    pub uf: String,

}

#[derive(Default)]
pub struct Cliente {
    pub id: usize,
    pub nome: String,
    pub cadastro: String,
    pub endereco: Endereco,
    pub telefone: String,
    //pub email: String,

}

    