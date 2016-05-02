package generativegrammar;

class Generator {
    var rules :Map<String, Array<{ probability :Null<Float>, children :Array<String> }>>;
    var random_func :Void->Float = Math.random;
    var validation_func :String->Bool = null;

    public function new() {
        rules = new Map();
    }

    public function add_rules(s :String) {
        var lexer = new GeneratorParser.Lexer(byte.ByteData.ofString(s));
        var ts = new hxparse.LexerTokenSource(lexer, GeneratorParser.Lexer.tok);
        var parser = new GeneratorParser.Parser(ts);
        var parsed :Array<GeneratorParser.Expr> = parser.parse();
        for (p in parsed) {
            var r = GeneratorParser.StringEvaluator.eval(p);
            add_rule(r.node, { probability: r.probability, children: r.children });
        }
    }

    public function add_rule(key :String, probability :{ probability :Null<Float>, children :Array<String> }) {
        if (!rules.exists(key)) rules[key] = [];
        rules[key].push(probability);
    }
    
    function get_replacements(key :String) :Array<{ probability :Null<Float>, children :Array<String> }> {
        var replacements = rules[key];
        if (replacements == null) return [];
        if (validation_func == null) return replacements;
        
        var results = [];
        for (r in replacements) { 
            var valid_children = r.children.filter(validation_func);
            if (valid_children.length > 0) results.push({ probability: r.probability, children: valid_children });
        }
        return results;
    }

    public function set_random(rand_func :Void->Float) {
        random_func = rand_func;
    }
    
    public function set_validation(valid_func :String->Bool) {
        validation_func = valid_func;
    }

    public function generate(symbol :String) :Tree<String> {
        var replacements = get_replacements(symbol);
        
        var probability_sum = 0.0;
        for (r in replacements) {
            probability_sum += (r.probability != null ? r.probability : 1);
        }
        var random_probability = probability_sum * random_func();
        var summing = 0.0;
        for (r in replacements) {
            summing += (r.probability != null ? r.probability : 1);
            if (summing < random_probability) continue;
            
            var children = [ for (c in r.children) generate(c) ];
            return Node(symbol, children);
        }

        return Leaf(symbol);
    }
}
