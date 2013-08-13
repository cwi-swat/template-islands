module lang::makaron::IDE

import util::IDE;
import ParseTree;
import lang::makaron::Template;
import lang::makaron::EvalFuncOrg;
import lang::makaron::Reparse;
import lang::makaron::ModelIDE;
import IO;


TString runExample(loc template, loc model) {
  tree = parse(#Text, template);
  mSrc = readFile(model);
  pt = parseModel(mSrc, model).top;
  m = implodeModel(pt);
  gen = run(tree, ("<pt.name>": m));
  return gen;
}

void setup() {
  map[loc, TString] table = ();

  registerLanguage("Makaron", "mak", Tree(str src, loc org) {
    return parse(#Text, src, org);
  });
  
  registerContributions("Makaron", {
    builder(set[Message] (Text tree) {
      outfile = tree@\loc[extension="generated"];
      mLoc = tree@\loc[extension="modl"];
      // remove offset etc. IO barfs on it.
      mLoc = |<mLoc.scheme>://<mLoc.authority><mLoc.path>|;
      println("Reading <mLoc>");
      mSrc = readFile(mLoc);
      pt = parseModel(mSrc, mLoc).top;
      m = implodeModel(pt);
      gen = run(tree, ("<pt.name>": m));
      writeFile(outfile, yield(gen));
      println("Storing generated file in <outfile>");
      println("");
      table[outfile] = gen;
      return {};   
    })
  });

  setupModelIDE();

  registerLanguage("Generated", "generated", Tree(str src, loc org) {
    println("ORG = <org>");
    println("");
    if (k <- table, k.path == org.path) {
      return reparse(table[k], org);
    }
    return appl(prod(sort("ERROR"), [], {}), []);   
  });
  
  
}