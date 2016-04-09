
enum Token {
    TSymbol(s :String);
    TTerminal(s :String);
    TArrow;
    TPlus;
    TBracketOpen;
    TBracketClose;
    TNumber(v :Float);
    TEof;
    TEol;
}

enum Construct {
    Symbol(s :String);
    Terminal(s :String);
}

enum Expr {
    EGenerator(node :Construct, probability :Null<Float>, children :Array<Construct>);
}

class Lexer extends hxparse.Lexer implements hxparse.RuleBuilder {
    static public var tok = @:rule [
        "=>" => TArrow,
        "+" => TPlus,
        "[" => TBracketOpen,
        "]" => TBracketClose,
        "[A-Z][a-zA-Z0-9_]*" => TSymbol(lexer.current), // symbol; uppercase starting letter
        "[a-z][a-zA-Z0-9_]*" => TTerminal(lexer.current),  // terminal; lowercase starting letter
        "(([1-9][0-9]*)|0)(.[0-9]+)?" => TNumber(Std.parseFloat(lexer.current)),
        "#[^\n\r]*" => lexer.token(tok), // comment
        "[\t ]" => lexer.token(tok), // whitespace
        "[\n\r]" => TEol, // line break
        "" => TEof
    ];
}

class Parser extends hxparse.Parser<hxparse.LexerTokenSource<Token>, Token> implements hxparse.ParserBuilder {
    public function parse() :Array<Expr> {
        return parseStatements([]);
    }

    function parseStatements(stm :Array<Expr>) :Array<Expr> {
        return switch stream {
            case [TSymbol(s), v = parseProbability(), TArrow, first = parseString(), rest = parseGenerators()]:
                stm.push(EGenerator(Symbol(s), v, [first].concat(rest)));
                parseStatements(stm);
            case [TEol]: parseStatements(stm);
            case [TEof]: stm;
        }
    }

    function parseProbability() :Null<Float> {
        return switch stream {
            case [TBracketOpen, TNumber(v), TBracketClose]: v;
            case _: null;
        }
    }

    function parseGenerators() :Array<Construct> {
        return switch stream {
            case [TPlus, s = parseString(), e = parseGenerators()]: [s].concat(e);
            case [TEol]: [];
            case [TEof]: [];
        }
    }

    function parseString() :Construct {
        return switch stream {
            case [TSymbol(s)]: Symbol(s);
            case [TTerminal(s)]: Terminal(s);
        }
    }
}

class StringEvaluator {
    static public function extract_value(c :Construct) :String {
        return switch (c) {
            case Symbol(s): s;
            case Terminal(s): s;
        };
    }

    static public function eval(e :Expr) :{ node: String, probability :Null<Float>, children :Array<String> } {
        return switch (e) {
            case EGenerator(construct, value, children): {
                node: extract_value(construct),
                probability: value,
                children: [ for (child in children) extract_value(child) ]
            };
        };
    }
}
