#[derive(Default, Clone)]
pub struct ItemPedido {
    pub produto_nome: String,
    pub quantidade: usize,
    pub valor: f64,
}

#[derive(Default, Clone)]
pub struct Pedido {
    pub id: usize,
    pub cliente_id: usize, 
    pub itens: Vec<ItemPedido>,
    pub valor_total: f64,
    pub data: String,
}