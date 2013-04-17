require 'treetop'
require 'docula/grammars/csimple'

require 'test/unit'

class TestCSimple < Test::Unit::TestCase
  def setup
    @parser = CSimpleParser.new
  end

  def test_fib
    assert_not_nil @parser.parse(File.read("tests/csimple/test_fib.h"))
    assert_not_nil @parser.parse(File.read("tests/csimple/test_fib.c"))
  end
end
