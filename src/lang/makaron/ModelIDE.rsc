module lang::makaron::ModelIDE

import lang::makaron::Model;
import lang::makaron::ModelImplode;
import lang::makaron::State;
import lang::makaron::ParseTemplate;
import lang::makaron::EvalFuncOrg;


import ParseTree;
import util::IDE;
import IO;


value implodeModel(Model m) = implode(m.theModel);

start[Model] parseModel(str src, loc org) = parse(#start[Model], src, org);

void setupModelIDE() {

  registerLanguage("Model", "modl", Tree(str src, loc org) {
    return parseModel(src, org);
  });
  
  registerContributions("Model", {
    builder(set[Message] (Tree tree) {
      if (Model mPt := tree.top) {
        outfile = mPt@\loc[extension="generated"];
        tLoc = mPt@\loc[extension="mak"];
        pt = parseTemplate(tLoc);
        m = implodeModel(mPt);
        gen = run(pt, ("<mPt.name>": m));
        // NB: update table before write to disk to have
        // the editor see the update when refreshing.
        table[outfile.path] = gen;
        println("OUTFILE.path = <outfile.path>");
        println("Table is");
        iprintln(table);
        writeFile(outfile, yield(gen));
        println("Storing generated file in <outfile>");
        println("");
        return {};
      }   
      return {error("Not a model tree", tree@\loc)};
    })
  });
  
  
}