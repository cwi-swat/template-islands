module lang::makaron::Reparse

import lang::makaron::EvalFuncOrg;
import ParseTree;
import String;
import List;
import IO;

Tree reparse(TString t, loc org) {
  map[loc, str] docs = ();

  loc prev = |<org.scheme>://<org.authority><org.path>|(0, 0, <1,1>, <1,1>);
  args = for (frag <- t) {
    switch (frag) {
      case string(loc l, str s): {
        prev = makeLocation(prev, s);
        append appl(prod(lex("Fragment"), [], {}), 
          [char(c) | c <- chars(s)])
             [@link=l]
             [@\loc=prev];
      }
      case model(Path path, loc l, loc mLoc,  str s): { 
        prev = makeLocation(prev, s);
        docs[prev] = intercalate(".", path);
        append appl(prod(lex("Model"), [], {\tag("category"("MetaVariable"))}), 
           [char(c) | c <- chars(s)])
             [@link=l][@\loc=prev];
      }
    }
  }
  len = prev.offset + prev.length;
  l = |<org.scheme>://<org.authority><org.path>|(0, len, <1,1>, <prev.end.line, prev.end.column>);
  cfArgs = ( [ args[0] ] | it + [appl(prod(\layouts("Fake"), [], {}), []), x]  | x <- args[1..] );
  return appl(regular(\iter-star(sort("Element"))), cfArgs)[@\loc=l][@docs=docs];
}

loc makeLocation(loc prev, str s) {
  println("MAKING loc for `<s>`");
  loc new = prev;
  println("prev = <prev>");
  
  new.offset += prev.length;
  println("new offset: <new.offset>");
  
  new.length = size(s);
  println("new length: <new.length>");
  
  new.begin = prev.end;
  println("new begin: <new.begin>");
  
  newlines =  size([ 10 | 10 <- chars(s)]); //count("\n", s);
  println("Num of newlines in `<s>`: <newlines>");
  println(chars(s));
  new.end.line += newlines;
  println("new end line: <new.end.line>");

  int col;
  if (newlines == 0) {
    col = new.end.column + size(s);  
  }
  else {  
    col = size(substring(s, findLast(s, "\n")));
  }
  println("new end column should be: <col>");
  new.end.column = col;
  
  return new;
}

list[int] find(str sub, str src) {
  result = [];
  int last = 0;
  while (/^<pre:.*?><sub><post:.*?>$/ := src) {
    result += [last + size(pre)];
    last += size(pre) + size(sub);
    src = post;
  }
  return result;
}

int count(str sub, str src) {
  return size(find(sub, src));
}

int lastIndexOf(str sub, str src) {
  return last(find(sub, src));
}