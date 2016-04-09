import haxe.unit.TestRunner;
import generativegrammar.GeneratorParser.Lexer;
import generativegrammar.GeneratorParser.Parser;

class Test {
    static public function get_parser(s :String) {
        var lexer = new Lexer(byte.ByteData.ofString(s));
        var ts = new hxparse.LexerTokenSource(lexer, Lexer.tok);
        return new Parser(ts);
    }

    static public function parse(s :String) {
        try {
            var parser = get_parser(s);
            parser.parse();
        } catch (e :hxparse.ParserError) {
            return false;
        }
        return true;
    }

    static function main() {
        var r = new haxe.unit.TestRunner();
        r.add(new ValidCases());
        r.add(new InvalidCases());
        r.run();
    }
}

class ValidCases extends haxe.unit.TestCase {
    function validate(s :String) {
        assertTrue(Test.parse(s));
    }

    public function testBasic() {
        validate('Symbol => Symbol + terminal');
        validate('Symbol => terminal1');
        validate('Symbol => terminal_blah1 + terminal2 + terminal3');
    }

    public function testMultiline() {
        validate("Symbol => Symbol1 + Symbol2\nSymbol1 => terminal");
    }

    public function testComments() {
        validate('# blah');
        validate('# this is a comment\n\rSymbol => Symbol1 + Symbol2\nSymbol1 => terminal');
    }

    public function testProbablities() {
        validate('Symbol [20]=> terminal1');
        validate('Symbol [12.3]=> terminal1');
        validate('Symbol [3.4567989]=> terminal1');
    }
}

class InvalidCases extends haxe.unit.TestCase {
    function invalidate(s :String) {
        assertFalse(Test.parse(s));
    }

    public function testBasic() {
        invalidate('Symbol => Symbol terminal');
        invalidate('Symbol => Symbol ++ terminal');
        invalidate('Symbol =>=> term');
        invalidate('term => term2');
    }
}
