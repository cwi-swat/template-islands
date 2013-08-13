module lang::makaron::EvalFunc

import lang::makaron::Template;
import IO;
import List;

alias Env = map[str, value];
alias PEnv = map[Id, Closure];

alias Closure = tuple[{Id ","}* formals, Block body];

alias Result = tuple[PEnv, str];

str run(Text t, Env env) = r[1]
  when Result r := eval(t, env, ()); 

Result eval((Text)`<Elt* es>`, Env env, PEnv penv) {
  out = "";
  for (e <- es) {
    <penv, src> = eval(e, env, penv);
    out += src;
  }
  return <penv, out>;
}
  
Result eval((Elt)`<Water w>`, Env env, PEnv penv) = eval(w, env, penv);
Result eval((Elt)`<Stat s>`, Env env, PEnv penv) = eval(s, env, penv);
  
Result eval((Stat)`$def <Id f>(<{Id ","}* ps>) <Block b>`, Env env, PEnv penv) 
  = <penv + (f: <ps, b>), "">; 
  
Result eval((Stat)`$if (<Expr c>) <Block b>`, Env env, PEnv penv) 
  = (true := evalExpr(c, env)) ? eval(b, env, penv) : <penv, "">;
  
Result eval((Stat)`$if (<Expr c>) <Block b> $else <Block eb>`, Env env, PEnv penv) 
  = (true := evalExpr(c, env)) ? eval(b, env, penv) : eval(eb, env, penv);

Result eval((Stat)`$for (<Id x>: <Expr e>) <Block b>`, Env env, PEnv penv)  {
  out = "";
  if (list[value] xs := evalExpr(e, env)) {    
    for (v <- xs) {
      <penv, src> = eval(e, env + ("<x>": v), penv);
      out += src;
    }
  }
  return <penv, out>;
}

Result eval((Stat)`$<Expr e>;`, Env env, PEnv penv) = <penv, "<evalExpr(e, env)>">;  

Result eval((Stat)`$(<Id f> <{Expr ","}* es>)`, Env env, PEnv penv) {
  if (f in penv) {
    args = [ evalExpr(e, env) | e <- es ];
    i = 0;
    for (frm <- penv[f].formals, i < size(args)) {
      env += ("<frm>": args[i]);
      i += 1;
    }
    return eval(penv[f].body, env, penv); 
  }
  return <penv, "">;
}  

Result eval((Block)`{<Elt* es>}`, Env env, PEnv penv) {
  out = "";
  for (e <- es) {
    <penv, src> = eval(e, env, penv);
    out += src;
  }
  return <penv, out>;
}


value evalExpr((Expr)`<Id x>`, Env env) = env["<x>"]
  when bprintln("X = <x>"), env["<x>"]?;

value evalExpr((Expr)`<Expr obj>.<Id f>`, Env env) = x["<f>"]
  when map[str,value] x := evalExpr(obj, env), x["<f>"]?;
  
default value evalExpr(Expr e, Env env) = "";

Result eval((Water)`\\$`, Env env, PEnv penv) = <penv, "$">;

default Result eval(Water w, Env env, PEnv penv) = <penv, "<w>">;

