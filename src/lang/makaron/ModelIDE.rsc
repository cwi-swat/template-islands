module lang::makaron::ModelIDE

import lang::makaron::Model;
import lang::makaron::ModelImplode;

import ParseTree;
import util::IDE;


value implodeModel(Model m) = implode(m.theModel);

start[Model] parseModel(str src, loc org) = parse(#start[Model], src, org);

void setupModelIDE() {

  registerLanguage("Model", "modl", Tree(str src, loc org) {
    return parseModel(src, org);
  });
  
}