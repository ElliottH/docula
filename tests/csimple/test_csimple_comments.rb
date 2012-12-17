require 'rubygems'
require 'treetop'

require 'test/unit'

require 'grammars/csimple.rb'

class TestCSimpleComments < Test::Unit::TestCase
  def setup
    @parser = CSimpleParser.new
  end

  def test_comments
    assert_not_nil @parser.parse('/* Test */')
    assert_not_nil @parser.parse('/**/')
    assert_not_nil @parser.parse(
      "/*
       *
       * Multiline!
       *
       */")

    assert_not_nil @parser.parse("// Hi there.\n")
    assert_not_nil @parser.parse("// Hi there.
                                 // And another!\n")

    assert_not_nil @parser.parse("# Hi there.\n")
    assert_not_nil @parser.parse("# Hi there.
                                 # And another!\n")
  end

  def test_docstrings
    assert_not_nil @parser.parse('/** Test */')
    assert_not_nil @parser.parse('/***/')
    assert_not_nil @parser.parse(
      "/**
       *
       * Multiline!
       *
       */")

    assert_not_nil @parser.parse("/// Hi there.\n")
    assert_not_nil @parser.parse("/// Hi there.
                                 /// And another!\n")

    assert_not_nil @parser.parse("## Hi there.\n")
    assert_not_nil @parser.parse("## Hi there.
                                 ## And another!\n")
  end

  def test_directive
    assert_not_nil @parser.parse("#include <foo.h>\n")
  end
end
