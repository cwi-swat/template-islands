module lang::makaron::EvalFuncOrg

import lang::makaron::Template;
import IO;
import List;
import ParseTree;
import lang::box::util::Box;

alias Value = tuple[Path path, value val];
alias Env = map[str, Value];
alias PEnv = map[Id, Closure];

alias Closure = tuple[{Id ","}* formals, Block body];

alias Result = tuple[PEnv, BString];

alias Path = list[value];

// extension
data Box
  = string(loc org, str val)
  | model(Path path, loc org, str val)
  ;

alias BString = list[Box];

BString nil() = [];

BString concat(BString t1, BString t2) = t1 + t2;

Text testMenu() 
 = parse(#Text, |project://template-islands/src/lang/makaron/menu.mak|);
  
public map[str, value] MENU_MODEL =
  ("name": "Menu",
   "hasKids": true,
   "kids": [
     ("name": "Home", "hasKids": false),
     ("name": "Contact", "hasKids": false),
     ("name": "About", "hasKids": false)
   ]);


loc concatLocs(loc l1, loc l2) {
  l = l1;
  l.length = l1.length + l2.length;
  l.end.column = l2.end.column;
  l.end.line = l2.end.line;
  return l;
}

TString run(Text t, map[str, value] m) = r[1]
  when Result r := eval(t, (k: <[k], m[k]> | k <- m), ()); 

Result eval((Text)`<Elt* es>`, Env env, PEnv penv) {
  out = nil();
  for (e <- es) {
    <penv, src> = eval(e, env, penv);
    out = concat(out, src);
  }
  return <penv, out>;
}
  
Result eval((Elt)`<Water w>`, Env env, PEnv penv) = eval(w, env, penv);
  
Result eval((Elt)`<Stat s>`, Env env, PEnv penv) = eval(s, env, penv);
  
Result eval((Stat)`$def <Id f>(<{Id ","}* ps>) <Block b>`, Env env, PEnv penv) 
  = <penv + (f: <ps, b>), nil()>; 
  
Result eval((Stat)`$if (<Expr c>) <Block b>`, Env env, PEnv penv) 
  = (<_, true> := evalExpr(c, env)) ? eval(b, env, penv) : <penv, nil()>;
  
Result eval((Stat)`$if (<Expr c>) <Block b> $else <Block eb>`, Env env, PEnv penv) 
  = (<_, true> := evalExpr(c, env)) ? eval(b, env, penv) : eval(eb, env, penv);

Result eval((Stat)`$for (<Id x>: <Expr e>) <Block b>`, Env env, PEnv penv)  {
  out = nil();
  if (<Path path, list[value] xs> := evalExpr(e, env)) {
    println("VALUES = <xs>");
    i = 0;    
    for (v <- xs) {
      <penv, src> = eval(b, env + ("<x>": <path + [i], v>), penv);
      out = concat(out, src);
      i += 1;
    }
  }
  return <penv, out>;
}

Result eval((Stat)`$<Expr e>;`, Env env, PEnv penv) 
  = <penv, [model(path, e@\loc, "<v>")]>
  when <Path path, value v> := evalExpr(e, env), bprintln("INTER : <v>"), isAtom(v);
  
bool isAtom(num _) = true;
bool isAtom(str _) = true;
bool isAtom(bool _) = true;
default bool isAtom(value _) = false;

Result eval((Stat)`$(<Id f> <{Expr ","}* es>)`, Env env, PEnv penv) {
  if (f in penv) {
    args = [ evalExpr(e, env) | e <- es ];
    i = 0;
    for (frm <- penv[f].formals, i < size(args)) {
      println("Binding <frm> to <args[i]>");
      env += ("<frm>": args[i]);
      i += 1;
    }
    return eval(penv[f].body, env, penv); 
  }
  return <penv, nil()>;
}  

Result eval((Block)`{<Elt* es>}`, Env env, PEnv penv) {
  out = nil();
  for (e <- trim(es)) {
    <penv, src> = eval(e, env, penv);
    out = concat(out, src);
  }
  return <penv, out>;
}

list[Elt] trim(/* Elt* es */ Tree es) {
  atStart = false;
  list[Elt] result = [];
  buf = [];
  for (Elt e <- es.args) {
    ws = isWhitespace(e);
    if (atStart, ws) {
      continue;
    }
    atStart = false;
    if (!ws) {
      result += buf;
      buf = [];
      result += [e];
    }
    if (ws) {
      buf += [e];
    }
  }
  return result;
}

// slow, but...
bool isWhitespace(Tree t) = /^[ \t\n\r]*$/ := "<t>";

Value evalExpr((Expr)`<Id x>`, Env env) 
  = env["<x>"]
  when bprintln("evaling <x>"), env["<x>"]?, bprintln("RESULT = <env["<x>"]>"); 

Value evalExpr((Expr)`<Expr obj>.<Id f>`, Env env) 
  = <path + ["<f>"], x["<f>"]>
  when bprintln("FIELD: <obj>.<f>"), 
  <Path path, map[str,value] x> := evalExpr(obj, env), 
    bprintln("X = <x>"), x["<f>"]?,
    bprintln("Returning: <x["<f>"]>");
  
default Value evalExpr(Expr e, Env env) = <[], "">;

Result eval(t:(Water)`\\$`, Env env, PEnv penv) = <penv, [string(t@\loc, "$")]>;

default Result eval(Water w, Env env, PEnv penv) = <penv, [string(w@\loc, "<w>")]>;

