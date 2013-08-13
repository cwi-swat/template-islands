module lang::makaron::Model

extend lang::std::Whitespace;
extend lang::std::Layout;

import String;
import ParseTree;


// JSON like

start syntax Model
  = model: "model" Id name Value theModel
  ;
  
syntax KeyVal = Id ":" Value;

syntax Value
  = integer: Int
  | string: String
  | boolean: Bool
  | array: "[" {Value ","}* "]"
  | object: "{" {KeyVal ","}* "}"
  ;
  
lexical Int = [0-9]+ !>> [0-9];

lexical String = [\"] StrChar* [\"] ;
lexical StrChar 
  = ![\"\\]
  | [\\][\"\\]
  ;
  
syntax Bool = "true" | "false";

lexical Id
  = [a-zA-Z_0-9] !<< ([a-zA-Z_][a-zA-Z_0-9]*) !>> [a-zA-Z_0-9];   
  
  
