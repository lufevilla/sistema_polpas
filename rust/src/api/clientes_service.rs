use crate::{models::cliente::Cliente, banco_de_dados::database_cl::*, error::AppError};

#[flutter_rust_bridge::frb]
pub async fn incluir_cliente_service(cliente: Cliente) -> Result<(), AppError> {
    checagem_presenca_dados(&cliente)?;

    match pesquisa_cliente_db(&cliente.nome, &cliente.cadastro) {
        Ok(true) => incluir_cliente_db(&cliente),
        Ok(false) => Err(AppError::ClienteJaExiste),
        Err(e) => Err(e),
    }
}

#[flutter_rust_bridge::frb]
pub async fn atualizar_cliente_service(cliente: Cliente, cliente_id: i64) -> Result<(), AppError> {
    checagem_presenca_dados(&cliente)?;
    atualizar_cliente_db(&cliente, cliente_id)
}

#[flutter_rust_bridge::frb]
pub async fn excluir_cliente_service(cliente: Cliente, cliente_id: i64) -> Result<(), AppError> {
    excluir_cliente_db(cliente_id)
}

fn checagem_presenca_dados(cliente: &Cliente) -> Result<(), AppError> {
    let campos_obrigatorios = [
        ("Nome", cliente.nome.as_str()),
        ("CPF/CNPJ", cliente.cadastro.as_str()),
        ("Telefone", cliente.telefone.as_str()),
        ("CEP", cliente.endereco.cep.as_str()),
        ("Logradouro", cliente.endereco.logradouro.as_str()),
        ("Número", cliente.endereco.numero.as_str()),
        ("Bairro", cliente.endereco.bairro.as_str()),
        ("Município", cliente.endereco.municipio.as_str()),
        ("UF", cliente.endereco.uf.as_str()),
    ];
    if let Some((nome_campo, _)) = campos_obrigatorios.iter().find(|(_, val)| val.trim().is_empty()) {
        return Err(AppError::DadosNaoInseridos(nome_campo.to_string()));
    }
    Ok(())
}
