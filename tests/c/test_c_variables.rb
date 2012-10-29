require 'rubygems'
require 'treetop'

require 'test/unit'

require 'lib/grammars/c.rb'

class TestCVariables < Test::Unit::TestCase
  def setup
    @parser = CParser.new
  end

  def test_declarations
    assert_not_nil @parser.parse("int a;")
    assert_not_nil @parser.parse("int i;\n")
    assert_not_nil @parser.parse("int i, j;")
    assert_not_nil @parser.parse("int i,j,k;")
    assert_nil @parser.parse("int i j;")

    assert_not_nil @parser.parse("struct foo bar;")
    assert_not_nil @parser.parse("struct foo bar, baz;")
    assert_nil @parser.parse("struct baz;")

    assert_not_nil @parser.parse("extern int a;")
    assert_not_nil @parser.parse("static union bob cat;")
    assert_nil @parser.parse("static union bob;")
    assert_nil @parser.parse("extern union;")

    assert_not_nil @parser.parse("int* j;")
    assert_not_nil @parser.parse("int *j;")

    assert_not_nil @parser.parse("int *i, j;")
    assert_not_nil @parser.parse("int *i, *j;")

    assert_not_nil @parser.parse("int **i;")
    assert_nil @parser.parse("int ***j;")
    assert_nil @parser.parse("int* **k;")
  end

  def test_definitions
    assert_not_nil @parser.parse("int a = 42;")
    assert_not_nil @parser.parse("int i = 0;\n")
    assert_nil @parser.parse("int i =")
    assert_nil @parser.parse("int j = ;")

    assert_not_nil @parser.parse("int i = 1, j = 2;")
    assert_not_nil @parser.parse("int i, j = 2;")
    assert_not_nil @parser.parse("int i = 1,j;")
    assert_nil @parser.parse("int k = 0, l = ;")

    assert_not_nil @parser.parse("struct foo bar = baz;")
    assert_not_nil @parser.parse("static struct foo bar = baz;")
    assert_not_nil @parser.parse("struct bob cat = meow, dog = woof;")
    assert_not_nil @parser.parse("struct bob cat = meow, dog;")
    assert_nil @parser.parse("struct foo = baz;")
    assert_nil @parser.parse("struct foo = bar, baz =;")

    assert_not_nil @parser.parse("int *j = i;")

    assert_not_nil @parser.parse("int j = ++i;")
    assert_not_nil @parser.parse("int j = i * j;")
    assert_not_nil @parser.parse("int j = i++;")
    assert_not_nil @parser.parse("int i = i ? a : b;")
    assert_not_nil @parser.parse("int i = i > 2 ? a : b;")
    assert_not_nil @parser.parse("int i = i > 2 ? a * b : c;")
  end
end
