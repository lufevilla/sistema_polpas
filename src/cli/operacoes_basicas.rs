use std::io;


pub fn leitura() -> String {

    let mut input: String = String::new();
    io::stdin().read_line(&mut input).expect("deu ruim");
    
    input.trim().to_string()
    

}

pub fn leitura_dados() -> usize {

    let mut input: String = String::new();
    io::stdin().read_line(&mut input).expect("deu ruim");

   //Ao deixar o ; na última linha, o compilador entende que a função terminou sem retornar nada, gerando o erro de tipo incompatível (expected i32, found ()).
    input.trim().parse().expect("deu ruim meu, não converti")     

}

pub fn limpar()  {

    clearscreen::clear().expect("erro ao limpar a tela");
     

} 

pub fn pausar(x: u64) {

    use std::thread;
    use std::time::Duration;

    thread::sleep(Duration::from_secs(x));
}
