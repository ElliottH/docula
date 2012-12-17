require 'rubygems'
require 'treetop'

require 'test/unit'

require 'grammars/c.rb'

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
    assert_not_nil @parser.parse("int *j = i;")

    assert_not_nil @parser.parse("long k = 8589934592L;")
    assert_not_nil @parser.parse("int l = 0xBEEF;")
    assert_not_nil @parser.parse("long m = 2e45;")
    assert_not_nil @parser.parse("float f = 400.2;")
    assert_not_nil @parser.parse("double d = -9000.;")
    assert_not_nil @parser.parse("double e = .16;")

    #assert_nil @parser.parse("float f = char;")

    assert_not_nil @parser.parse("size_t j = sizeof i;")
    assert_not_nil @parser.parse("size_t sint = sizeof (int);")

    assert_not_nil @parser.parse("int j = ++i;")
    assert_not_nil @parser.parse("int j = i++;")
    assert_not_nil @parser.parse("int *k = &j;")
    assert_not_nil @parser.parse("int l = *k;")
    assert_not_nil @parser.parse("char a = ~b;")

    assert_not_nil @parser.parse("int d += 42;")
    assert_nil @parser.parse("int d == 42;")

    assert_not_nil @parser.parse("int a = a + b;")
    assert_not_nil @parser.parse("int j = i * j;")
    assert_not_nil @parser.parse("int i = i ? a : b;")
    assert_not_nil @parser.parse("int i = i > 2 ? a : b;")
    assert_not_nil @parser.parse("int i = i > 2 ? (a * b) : c;")
    assert_not_nil @parser.parse("int i = i > 2 ? a * b : c;")
    assert_nil @parser.parse("int x = y ? z;")
    assert_nil @parser.parse("int x = y * ;")

    assert_not_nil @parser.parse("int a = (a + b) * b * (c+d);")

    assert_not_nil @parser.parse("int b = a;")
    assert_not_nil @parser.parse("int b = a ? b * c % d : e;")
    assert_not_nil @parser.parse("int b = (a ? (b * c) % d : e);")
    assert_not_nil @parser.parse("int b = (a ? ((b * c) % d) : e);")

    assert_not_nil @parser.parse("int c = (a == b);")
    assert_not_nil @parser.parse("int c = a(b);")

    assert_not_nil @parser.parse("int z = ++y;")
    assert_not_nil @parser.parse("int z = y++;")

    assert_not_nil @parser.parse("int arr[100];")
    assert_not_nil @parser.parse("int arr[n] = 10;")
    assert_not_nil @parser.parse("int arr[x][y];")

    assert_not_nil @parser.parse("int a = 'a';")
    assert_not_nil @parser.parse("int a = '\"';")
    assert_nil @parser.parse("int a = '';")

    assert_not_nil @parser.parse("int arr[2] = { 5 * 6, 6 * 7 };")
  end

  def test_structs
    assert_not_nil @parser.parse("struct foo bar;")
    assert_not_nil @parser.parse("struct foo bar, baz;")

    assert_not_nil @parser.parse("extern int a;")
    assert_not_nil @parser.parse("static union bob cat;")
    assert_nil @parser.parse("extern union;")

    assert_not_nil @parser.parse("struct foo bar = baz;")
    assert_not_nil @parser.parse("static struct foo bar = baz;")
    assert_not_nil @parser.parse("struct bob cat = meow, dog = woof;")
    assert_not_nil @parser.parse("struct bob cat = meow, dog;")
    assert_nil @parser.parse("struct foo = baz;")
    assert_nil @parser.parse("struct foo = bar, baz =;")

    assert_not_nil @parser.parse("struct foo { int x; };")
    assert_not_nil @parser.parse("struct foo { int x; } bar;")
    assert_not_nil @parser.parse("struct foo { int x; float y; } bar;")
    assert_not_nil @parser.parse("struct f { int flag : 1; int num; } g;")

    assert_not_nil @parser.parse("struct foo bar = { 1, \"baz\" };")
    assert_not_nil @parser.parse("struct foo bar = { .a = 1, .b = \"baz\" };")
  end

  def test_enums
    assert_not_nil @parser.parse("enum BOOL { FALSE, TRUE };")
    assert_not_nil @parser.parse("enum BOOL { TRUE = 1, FALSE = 0, MAYBE = 0.5 };")
    assert_not_nil @parser.parse("enum BOOL test;")
    assert_not_nil @parser.parse("enum BOOL test = TRUE;")
    assert_not_nil @parser.parse("enum BOOL { FALSE, TRUE } test;")
    assert_not_nil @parser.parse("enum BOOL { FALSE = 0, TRUE = 1 } test;")
  end
end
