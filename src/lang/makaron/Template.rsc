module lang::makaron::Template

extend lang::std::Whitespace;
extend lang::std::Layout;

lexical Text = Elt*;

lexical Elt
  = Water
  | Stat
  | Block
  ;

lexical Id
  = [a-zA-Z_0-9] !<< ([a-zA-Z_][a-zA-Z_0-9]*) \ Reserved !>> [a-zA-Z_0-9] 
  ;

keyword Reserved = "if" | "else" | "for" | "def"; 

syntax Stat
  = Q "if" "(" Expr ")" Block
  | Q "if" "(" Expr ")" Block Q "else" Block
  | Q "for" "(" Id ":" Expr ")" Block
  | Q "(" Id {Expr ","}* ")"
  | Q "def" Id "(" {Id ","}* ")" Block
  | Q Expr >> ";" ";"
  ;
  
syntax Expr 
  = Expr >> "." "." Id
  | Id
  ;
  
  
lexical Q = [\\] !<< "$" !>> [\ \t\n];
  
lexical Block = @Foldable "{" Elt* "}";  
  
lexical Water
  = WaterChar* WaterEndChar
  ;
  
  
// Bug: pgen fails on this: prod_WaterEndChar_WaterChar already defined.
//lexical WaterEndChar
//  = mid: WaterChar >> [$}]
//  | end: WaterChar $
//  ;

lexical WaterEndChar
  = mid: WaterChar >> [${}] 
  | end: WaterEOFChar !>> [\n] $
  ;
  
lexical WaterEOFChar = WaterChar;
  
lexical WaterChar
  = ![\\${}] 
  | [\\] !>> [$]
  | [\\][${}]
  ;
