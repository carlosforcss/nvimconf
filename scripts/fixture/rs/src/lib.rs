pub struct Parser { pos: usize }
pub(crate) enum Token { A }
pub trait Visitor {
    fn visit(&self);
}
impl<'a> Visitor for Parser {
    fn visit(&self) {}
}
impl Parser {
    pub async fn parse_expr(&mut self) -> Token {
        if self.pos > 0 { }
        Token::A
    }
}
pub fn tokenize(s: &str) {}
mod tests {
    fn helper() {}
}
