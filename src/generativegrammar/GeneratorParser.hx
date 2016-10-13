package generativegrammar;

enum Token {
    TUppercaseString(s :String);
    TLowercaseString(s :String);
    TArrow;
    TPlus;
    TBracketOpen;
    TBracketClose;
    TNumber(v :Float);
    TColon;
    TRequire;
    TDefine;
    TWeight;
    TExclaimationMark;
    TGreater;
    TLess;
    TEquals;
    TRequireAttribute;
    TDefineAttribute;
    TEof;
    TEol;
}

enum Construct {
    Symbol(s :String);
    Terminal(s :String);
}

// property, e.g. [weight:3.5]
// require,  e.g. [require:!boss] or [require:boss==4] or [require:boss>4]
// define,   e.g. [define:boss] or [define:boss=4]

typedef AttributeValues = { s :String, b :Bool, o :Operator, i :Int }; // s: name, b: not operator, o: comparator operator, i: value

enum AttributeType {
    PropertyAttribute(s :String, v :Float);
    RequireAttribute(a: AttributeValues);
    DefineAttribute(a: AttributeValues);
}

enum Operator {
    None;
    Equals;
    Less;
    Greater;
}

enum Expr {
    EGenerator(node :Construct, /* weight: Float, */ attributes :Array<AttributeType>, children :Array<Construct>);
}

class Lexer extends hxparse.Lexer implements hxparse.RuleBuilder {
    static public var tok = @:rule [
        "=>" => TArrow,
        "+" => TPlus,
        "[" => TBracketOpen,
        "]" => TBracketClose,
        ":" => TColon,
        "!" => TExclaimationMark,
        ">" => TGreater,
        "<" => TLess,
        "=" => TEquals,
        "weight" => TWeight,
        "require" => TRequire,
        "define" => TDefine,
        "[A-Z][a-zA-Z0-9_]*" => TUppercaseString(lexer.current), // symbol; uppercase starting letter
        "[a-z][a-zA-Z0-9_]*" => TLowercaseString(lexer.current),  // terminal; lowercase starting letter
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
            case [TUppercaseString(s), av = parseAttributes(), TArrow, first = parseString(), rest = parseGenerators()]:
                stm.push(EGenerator(Symbol(s), av, [first].concat(rest)));
                parseStatements(stm);
            case [TEol]: parseStatements(stm);
            case [TEof]: stm;
        }
    }

    function parseAttributes() :Array<AttributeType> {
        return switch stream {
            case [TBracketOpen, a = parseAttribute(), TBracketClose, l = parseAttributes()]: [a].concat(l);
            case _: [];
        }
    }

    function parseAttribute() :AttributeType {
        return switch stream {
            case [TWeight, TColon, TNumber(v)]: PropertyAttribute('weight', v);
            case [TRequire, TColon, v = parseAttributeValue()]: RequireAttribute(v);
            case [TDefine, TColon, v = parseAttributeValue()]: DefineAttribute(v);
        }
    }

    function parseAttributeValue() :AttributeValues {
        return switch stream {
            case [n = parseNot(), TLowercaseString(s), o = parseOperator(), v = parseValue()]: { s: s, b: n, o: o, i: v };
        }
    }

    function parseNot() :Bool {
        return switch stream {
            case [TExclaimationMark]: true;
            case _: false;
        }
    }

    function parseOperator() :Operator {
        return switch stream {
            case [TGreater]: Greater;
            case [TLess]: Less;
            case [TEquals]: Equals;
            case _: None;
        }
    }

    function parseValue() :Int {
        return switch stream {
            case [TNumber(v)]: Std.int(v);
            case _: 1;
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
            case [TUppercaseString(s)]: Symbol(s);
            case [TLowercaseString(s)]: Terminal(s);
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

    static public function eval(e :Expr) :{ node: String, probability :Array<AttributeType>, children :Array<String> } {
        return switch (e) {
            case EGenerator(construct, values, children): /* trace('attribute list is: $values'); */ {
                node: extract_value(construct),
                probability: values,
                children: [ for (child in children) extract_value(child) ]
            };
        };
    }
}
