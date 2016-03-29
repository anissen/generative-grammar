
enum Tree<T> {
    Leaf(v :T);
    Node(s :T, list :Array<Tree<T>>);
}

class Generator {
    var rules :Map<String, Array<{ value :Null<Float>, results :Array<String> }>>;

    public function new() {
        rules = new Map();
    }

    public function add_rule(key :String, value) {
        if (!rules.exists(key)) rules[key] = [];
        rules[key].push(value);
    }

    public function generate(symbol :String) :Array<String> {
        var replacements = rules[symbol];
        if (replacements == null || replacements.length == 0) return [];
        var replacement = replacements[Math.floor(replacements.length * Math.random())];
        var res = [symbol];
        for (r in replacement.results) res = res.concat(generate(r));
        return res;
    }

    public function generate_tree(symbol :String) :Tree<String> {
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

        var children = [ for (r in replacement.results) generate_tree(r) ];
        return Node(symbol, children);
    }
}

typedef GrammarType = { symbol :String, value :Null<Float>, results :Array<String> };

class Main {
    static function parse(s :String) :Array<GrammarType> {
        var lexer = new GeneratorParser.Lexer(byte.ByteData.ofString(s));
        var ts = new hxparse.LexerTokenSource(lexer, GeneratorParser.Lexer.tok);
        var parser = new GeneratorParser.Parser(ts);
        var results = [];
        try {
            var parsed :Array<GeneratorParser.Expr> = parser.parse();
            for (p in parsed) {
                results.push(GeneratorParser.TypeEvaluator.eval(p));
            }
        } catch (e :hxparse.ParserError) {
            trace('Parse error', e);
        }
        return results;
    }

    static function main() {

        var quest_grammar =
        "Quest => SubQuest + return + Reward
        SubQuest => TalkTo + Kill
        SubQuest => GoTo + Retrieve
        SubQuest [0.5]=> SubQuest + SubQuest
        TalkTo => Person
        GoTo => Location
        Kill => Monster
        Kill => Person
        Reward => treasure
        Reward [0.1]=> you_win
        #Reward => treasure + Reward
        Retrieve => treasure";

        var map_grammar = "
        Map => Region + Region
        Region => RegionType + RegionAffilication
        RegionType => island_small + Town
        RegionType => island_big + City + Town
        RegionAffilication => hostile
        RegionAffilication => neutral
        RegionAffilication => friendly
        Town => House + House
        City => city_center + House + House
        House => House + House
        House => shop
        House => blacksmith
        House => herbalist
        House => casino
        ";

        var encounter_grammar = "
        Encounter => Animals
        Encounter => druid + Animals
        Encounter => Monsters
        Encounter => Chief + Monster + Monster
        Encounter => leader + Bandits + Bandits
        Encounter => Bandits
        Animals => bear
        Animals => wolf + wolf
        Animals => rat + rat + rat
        Animals => bee + bee + bee
        Monsters => Monster + Monster
        Monsters => Monsters + Monster
        Monster => imp
        Monster => ogre
        Monster => slime
        Chief => mage
        Chief => berserker
        Bandits [0.5]=> Bandits + bandit
        Bandits => bandit
        ";

        var rules = parse(map_grammar);
        var generator = new Generator();
        for (r in rules) {
            generator.add_rule(r.symbol, { value: r.value, results: r.results });
        }

        function pad(size :Int) {
            var s = '';
            for (i in 0 ... size) s += ' ·';
            return s + ' ';
        }
        function print(s :String, index :Int) {
            //if (s.charAt(0) == s.charAt(0).toLowerCase()) trace(s); // only print lower-case strings
            trace(pad(index) + s);
        }
        function print_tree(t :Tree<String>, index :Int = 0) {
            return switch (t) {
                case Leaf(s): print(s, index);
                case Node(s, list): print(s, index); for (l in list) print_tree(l, index + 1);
                default: trace('Invalid!', index);
            }
        }
        var results_tree = generator.generate_tree('Map');
        print_tree(results_tree);
    }
}
