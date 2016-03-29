
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

enum Expr {
    EGenerator(symbol :String, value :Null<Float>, results :Array<String>);
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
            case [TSymbol(s), v = parseValue(), TArrow, first = parseString(), rest = parseGenerators()]:
                stm.push(EGenerator(s, v, [first].concat(rest)));
                parseStatements(stm);
            case [TEol]: parseStatements(stm);
            case [TEof]: stm;
        }
    }

    function parseValue() :Null<Float> {
        return switch stream {
            case [TBracketOpen, TNumber(v), TBracketClose]: v;
            case _: null;
        }
    }

    function parseGenerators() :Array<String> {
        return switch stream {
            case [TPlus, s = parseString(), e = parseGenerators()]: [s].concat(e);
            case [TEol]: [];
            case [TEof]: [];
        }
    }
    
    function parseString() :String {
        return switch stream {
            case [TSymbol(s)]: s;
            case [TTerminal(s)]: s;
        }
    }
}

class StringEvaluator {
    static public function eval(e :Expr) :String {
        return switch(e) {
            case EGenerator(s, v, r): '$s becomes $r' + (v != null ? ' with probability $v' : '');
        }
    }
}

class TypeEvaluator {
    static public function eval(e :Expr) :Dynamic {
        return switch(e) {
            case EGenerator(s, v, r): { symbol: s, value: v, results: r };
        }
    }
}