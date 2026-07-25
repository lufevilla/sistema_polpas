#[derive(Default,Clone)]
pub struct Produto {
    pub id_merc: usize,
    pub nome_merc: String,
    pub quantidade_est: usize
}

#[derive(Default, Clone)]
pub struct ItemPedido {
    pub id_item: usize,  
    pub produto_nome: String,
    pub quantidade: usize,
    pub valor: f64,
    pub subtotal: f64,  
}

#[derive(Default, Clone)]
pub struct Pedido {
    pub id: usize,
    pub cliente_id: usize, 
    pub itens: Vec<ItemPedido>,
    pub valor_total: f64,
    pub data: String,
}