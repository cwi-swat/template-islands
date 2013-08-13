module lang::makaron::Eval

import lang::makaron::Template;
import IO;

alias Env = map[str, value];

str eval((Text)`<Elt* es>`, Env env) 
  = ( "" | it + eval(e, env) | e <- es, bprintln("e= <e>"));
  
str eval((Elt)`<Water w>`, env) = eval(w, env);
str eval((Elt)`<Stat s>`, env) = eval(s, env);
  
str eval((Stat)`$def <Id f>(<{Id ","}* ps>) <Block b>`, Env env) 
  = 3;
  
str eval((Stat)`$if (<Expr c>) <Block b>`, Env env) 
  = (true := evalExpr(c, env)) ? eval(b, env) : "";
  
str eval((Stat)`$if (<Expr c>) <Block b> $else <Block eb>`, Env env) 
  = (true := evalExpr(c, env)) ? eval(b, env) : eval(eb, env);

str eval((Stat)`$for (<Id x>: <Expr e>) <Block b>`, Env env)
  = ( "" | it + eval(b, env + ("<x>": i)) | i <- xs )
  when list[value] xs := evalExpr(e, env);  

str eval((Stat)`$<Expr e>`, Env env) = "<evalExpr(e, env)>";  

str eval((Block)`{<Elt* es>}`, Env env) 
  = ( "" | it + eval(e, env) | e <- es );

// bug: eval(Elt* es,... gives unbound var (splicing?)
//

value evalExpr((Expr)`<Id x>`, Env env) = env["<x>"]
  when bprintln("X = <x>"), env["<x>"]?;

value evalExpr((Expr)`<Expr obj>.<Id f>`, Env env) = x["<f>"]
  when map[str,value] x := evalExpr(obj, env), x["<f>"]?;
  
default value evalExpr(Expr e, Env env) = "";

str eval((Water)`\\$`, Env env) = "$";

default str eval(Water w, Env env) = "<w>";

