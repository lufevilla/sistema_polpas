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

#[derive(Default, Clone)]
pub struct Movimentacoes {
    pub id_merc: i64, 
    pub quantidade: i64, 
    pub custo_unitario_compra: f64,
    pub tipo_movimentacao: String
}

impl Movimentacoes {
    pub fn custo_total_compra(&self) -> f64 {
        self.quantidade as f64 * self.custo_unitario_compra
    }      
}

//    id_movimentacao INTEGER PRIMARY KEY AUTOINCREMENT,
//             id_merc INTEGER NOT NULL,
//             tipo_movimentacao TEXT NOT NULL,        
//             quantidade INTEGER NOT NULL,             
//             custo_unitario_compra REAL,              
//             custo_total_compra REAL,                 
//             data_movimentacao DATETIME DEFAULT CURRENT_TIMESTAMP,
//             FOREIGN KEY (id_merc) REFERENCES estoque (id_merc) ON DELETE RESTRICT