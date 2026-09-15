#[derive(Default,Clone)]
pub struct Produto {
    pub id_merc: i64,
    pub nome_merc: String,
    pub quantidade_est: i64,
    pub quantidade_minima: i64, 
    pub valor_unitario: f64
}

#[derive(Default, Clone)]
pub struct ItemPedido {
    pub id_item: i64,  
    pub produto: Produto,
    pub quantidade: i64,
    pub valor: f64
}

impl ItemPedido {
    pub fn subtotal(&self) -> f64 {
        self.quantidade as f64 * self.valor
    }      
}

#[derive(Default, Clone)]
pub struct Pedido {
    pub id: i64,
    pub cliente_id: i64, 
    pub itens: Vec<ItemPedido>,
    pub valor_total: f64,
    pub data: String,
}