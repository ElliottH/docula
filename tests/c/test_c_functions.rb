require 'rubygems'
require 'treetop'

require 'test/unit'

require 'lib/grammars/c.rb'

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

  end
end
