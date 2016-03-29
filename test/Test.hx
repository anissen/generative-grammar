class Test {
    static public function main() {
        function get_parser(s :String) {
            var lexer = new GeneratorParser.Lexer(byte.ByteData.ofString(s));
            var ts = new hxparse.LexerTokenSource(lexer, GeneratorParser.Lexer.tok);
            return new GeneratorParser.Parser(ts);
        }

        function validate(s :String) {
            var parser = get_parser(s);
            try {
                var parsed :Array<GeneratorParser.Expr> = parser.parse();
                for (p in parsed) {
                    var actual = GeneratorParser.StringEvaluator.eval(p);
                    //trace(actual);
                }
            } catch (e :hxparse.ParserError) {
                trace('Parse error', e);
                trace('==> Validate failure: $s');
            }
        }

        function invalidate(s :String) {
            var parser = get_parser(s);
            try {
                var parsed :Array<GeneratorParser.Expr> = parser.parse();
                trace('==> Invalidate failure: "$s":');
                for (p in parsed) {
                    var actual = GeneratorParser.StringEvaluator.eval(p);
                    trace('----> $actual');
                }
            } catch (e :hxparse.ParserError) {
                // ok
            }
        }

        validate('Symbol => Symbol + terminal');
        validate('Symbol => terminal1');
        validate('Symbol => terminal_blah1 + terminal2 + terminal3');
        trace('------------');
        validate('# blah');
        validate("Symbol => Symbol1 + Symbol2\nSymbol1 => terminal");
        validate('# this is a comment\n\rSymbol => Symbol1 + Symbol2\nSymbol1 => terminal');
        trace('------------');
        validate('Symbol [20]=> terminal1');
        validate('Symbol [12.3]=> terminal1');
        validate('Symbol [3.4567989]=> terminal1');
        trace('------------');
        invalidate('Symbol => Symbol terminal');
        invalidate('Symbol => Symbol ++ terminal');
        invalidate('Symbol =>=> term');
    }
}
