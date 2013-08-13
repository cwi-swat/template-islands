module lang::makaron::ModelImplode

import lang::makaron::Model;
import ParseTree;
import String;

alias OrgValue = tuple[loc location, value theValue];  
  
OrgValue implode(x:(Value)`{ <{KeyVal ","}* kvs> }`) =
   <x@\loc, ( "<k>": implode(v) | (KeyVal)`<Id k>: <Value v>` <- kvs )>;
   
OrgValue implode(x:(Value)`[ <{Value ","}* vs> ]`) =
   <x@\loc, [ implode(v) | Value v <- vs ]>;
   
OrgValue implode(v:(Value)`<Int x>`) = <v@\loc, toInt("<x>")>;
OrgValue implode(v:(Value)`true`) = <v@\loc, true>;
OrgValue implode(v:(Value)`false`) = <v@\loc, false>;
OrgValue implode(v:(Value)`<String x>`) = 
  <v@\loc, replaceAll(replaceAll("<x>", "\\\\", "\\"), "\\\"", "\"")[1..-1]>;
   