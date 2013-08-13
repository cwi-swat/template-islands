module lang::makaron::Expressions

extend lang::std::Whitespace;
extend lang::std::Layout;

syntax Expr
  = Id
  | "[" {Expr ","}* "]"
  | left Expr "+" Expr
  > non-assoc Expr "\<" Expr  
  ;
