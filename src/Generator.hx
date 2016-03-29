
enum Tree<T> {
    Leaf(v :T);
    Node(s :T, list :Array<Tree<T>>);
}

class Generator {
    var rules :Map<String, Array<{ value :Null<Float>, results :Array<String> }>>;

    public function new() {
        rules = new Map();
    }

    public function add_rules(s :String) {
        var lexer = new GeneratorParser.Lexer(byte.ByteData.ofString(s));
        var ts = new hxparse.LexerTokenSource(lexer, GeneratorParser.Lexer.tok);
        var parser = new GeneratorParser.Parser(ts);
        var parsed :Array<GeneratorParser.Expr> = parser.parse();
        for (p in parsed) {
            var r = GeneratorParser.TypeEvaluator.eval(p);
            add_rule(r.symbol, { value: r.value, results: r.results });
        }
    }

    public function add_rule(key :String, value :{ value :Null<Float>, results :Array<String> }) {
        if (!rules.exists(key)) rules[key] = [];
        rules[key].push(value);
    }

    public function generate(symbol :String) :Tree<String> {
        var replacements = rules[symbol];
        if (replacements == null || replacements.length == 0) return Node(symbol, []);

        var value_sum = 0.0;
        for (r in replacements) value_sum += (r.value != null ? r.value : 1);
        var random_value = value_sum * Math.random();
        var summing = 0.0;
        var replacement = null;
        for (r in replacements) {
            summing += (r.value != null ? r.value : 1);
            if (summing < random_value) continue;
            replacement = r;
            break;
        }

        var children = [ for (r in replacement.results) generate(r) ];
        return Node(symbol, children);
    }
}
