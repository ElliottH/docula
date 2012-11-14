require 'rubygems'
require 'treetop'

require 'test/unit'

require 'grammars/c.rb'

class TestCFunctions < Test::Unit::TestCase
  def setup
    @parser = CParser.new
  end

  def test_declarations
    assert_not_nil @parser.parse("int a();")
    assert_not_nil @parser.parse("int a(int x);")
    assert_not_nil @parser.parse("int b(int x, float y);")

    assert_not_nil @parser.parse("inline union foo bar(int a, float b);")
    assert_not_nil @parser.parse("inline struct foo* bar(int a, char* x);")

    assert_nil @parser.parse("a();")
    assert_nil @parser.parse("int a(")
    assert_nil @parser.parse("int b);")
    assert_nil @parser.parse("inline union bar();")
  end

  def test_definitions
    assert_not_nil @parser.parse("void test() { return; }")
    assert_not_nil @parser.parse("int a(int x, int y) { return x; }")
    assert_not_nil @parser.parse("int a(int x, int y) { int x = x + y; return x; }")
    assert_not_nil @parser.parse("int a(int x, int y) { int x = x + y; return x + y; }")
    assert_not_nil @parser.parse("int a(int x, int y) { x = x + y; }")
    assert_not_nil @parser.parse("int b() { x = x + y; return x; }")

    assert_not_nil @parser.parse("int a(int x, int y) { return x == y; }")
    #assert_not_nil @parser.parse("int a(int x, int y) { y += x; }")
    #assert_not_nil @parser.parse("int a(int x, int y) {\ny += x;\nreturn y;\n}")
    #assert_not_nil @parser.parse("int a() {\n{\nx++;\n}\n}")

    assert_not_nil @parser.parse("int c() {\nif (a == b) {\nreturn x;\n}")

    assert_nil @parser.parse("int a() {{x++;}")

    assert_not_nil @parser.parse("int a(char *y) {\ny = \"Hello!\";\n}")
    assert_not_nil @parser.parse("int a(char *y) {\ny = \"Hello! {\";\n}")
  end
end
