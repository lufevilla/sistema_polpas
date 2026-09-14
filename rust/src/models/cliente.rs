use serde::{Deserialize, Serialize};

#[derive(Default, Debug, Clone, Serialize, Deserialize)]
pub struct Endereco {
    pub cep: String,
    pub logradouro: String,
    pub numero: String,
    pub complemento: Option<String>,
    pub bairro: String,
    pub municipio: String,
    pub uf: String,
}

#[derive(Default, Debug, Clone, Serialize, Deserialize)]
pub struct Cliente {
    pub id: i64,
    pub nome: String,
    pub cadastro: String,
    pub endereco: Endereco,
    pub telefone: String,
}
