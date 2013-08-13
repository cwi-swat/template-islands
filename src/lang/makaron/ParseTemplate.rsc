module lang::makaron::ParseTemplate

import lang::makaron::Template;
import ParseTree;

Text parseTemplate(loc l) = parse(#Text, l);

