
import GeneratorParser.Construct;

enum Tree<T> {
    Leaf(v :T);
    Node(s :T, list :Array<Tree<T>>);
}

class Generator {
    var rules :Map<Construct, Array<{ probability :Null<Float>, children :Array<Construct> }>>;
    var random_func :Void->Float = Math.random;

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
            add_rule(r.node, { probability: r.probability, children: r.children });
        }
    }

    public function add_rule(key :Construct, probability :{ probability :Null<Float>, children :Array<Construct> }) {
        if (!rules.exists(key)) rules[key] = [];
        rules[key].push(probability);
    }

    public function set_random(rand_func :Void->Float) {
        random_func = rand_func;
    }

    public function generate(symbol :Construct) :Tree<Construct> {
        var replacements = rules[symbol];
        if (replacements == null || replacements.length == 0) return Leaf(symbol);

        var probability_sum = 0.0;
        for (r in replacements) probability_sum += (r.probability != null ? r.probability : 1);
        var random_probability = probability_sum * random_func();
        var summing = 0.0;
        var replacement = null;
        for (r in replacements) {
            summing += (r.probability != null ? r.probability : 1);
            if (summing < random_probability) continue;
            replacement = r;
            break;
        }

        var children = [ for (r in replacement.children) generate(r) ];
        return Node(symbol, children);
    }
}
