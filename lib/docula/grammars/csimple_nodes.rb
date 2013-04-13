module CSimple
  class BaseNode < Treetop::Runtime::SyntaxNode
  end

  module Documentable
    def documented?
      docstring != {}
    end

    def docstring(stripped = true)
      doc = elements.detect { |elem| elem.class == DocstringNode }
      text = ""
      if doc == nil
        return {}
      elsif stripped
        text = doc.strip
      else
        text = doc.text_value
      end
      return {
        :text => text,
        :return => doc.returns,
        :params => doc.params
      }
    end
  end
  module Comment
    def strip
      # Remove all types of comments from text.
      result = text_value.gsub(%r{^\s*(/\*+|\*/?|///?|##?)}, "")
      # Remove all @annotations.
      result = result.gsub(/^\s*(@.*?\n)/, "")
      result.strip
    end
  end

  module NameAndType
    # Excuse the capitals, I need to avoid clashing with 'name' and 'type'
    def Name
      elements.detect do |elem|
        elem.class == CSimple::NameNode
      end.text_value.gsub(/\*+/, "").strip
    end
    def Type
      type = elements.detect do |elem|
        elem.class == CSimple::TypeNode
      end.text_value.strip

      stars = elements.detect do |elem|
        elem.class == CSimple::NameNode
      end.text_value.match(/(\*)+/).to_s

      return type + stars
    end
  end

  class CommentNode < BaseNode
    include Comment
  end
  class DocstringNode < BaseNode
    include Comment

    def file?
      return text_value.index(/\s@file\s/) != nil
    end

    def returns
      if (result = text_value.match(/\s@return\s/)) != nil
        result.post_match.match(/$/).pre_match
      end
    end

    def params
      param = []
      text_value.scan(/\s@param(?:\[(.*?)\])?\s(\w)\s(.*)$/) do |match|
        if match.length == 3
          param << {
            :flow => match[0],
            :name => match[1],
            :description => match[2]
          }
        end
      end
      return param
    end
  end

  class StartNode < BaseNode
    def functions
      elements.select { |element| element.class == FunctionNode }
    end
    def directives
      elements.select { |element| element.class == DirectiveNode }
    end
    def variables
      elements.select { |element| element.class == VariableNode }
    end
    def docstrings
      elements.select do |element|
        element.class == DocstringNode && element.file?
      end
    end
    def typedefs
      elements.select { |element| element.class == TypeDefNode }
    end
  end

  class DirectiveNode < BaseNode
    include Documentable

    def include?
      text_value.include? "#include"
    end

    def includes
      text_value.match(/#include\s+(?:<|")(.*?)(?:>|")/).captures.first
    end

    def define?
      text_value.include? "#define"
    end

    def defines
      elements.select do |elem|
        elem.class != DocstringNode
      end.collect do |elem|
        elem.text_value
      end.join.match(/#define\s+(.*?)\s+(.*?)$/).captures
      #text_value.match(/^#define\s+(.*?)\s+(.*?)$/).captures
    end
  end

  class TypeDefNode < BaseNode
    include Documentable

    def from
      elements.detect do |element|
        element.class == TypeNode
      end.text_value
    end
    def to
      elements.reverse_each.detect do |element|
        element.class == TypeNode
      end.text_value
    end
  end

  class VariableNode < BaseNode
    include Documentable
    include NameAndType
  end
  class FunctionNode < BaseNode
    include Documentable

    def prototype
      typ = elements.detect do |element|
        element.class == FunctionPrototypeNode
      end
      return {
        :name => typ.Name,
        :type => typ.Type,
        :arguments => typ.arguments
      }
    end
  end

  class FunctionPrototypeNode < BaseNode
    include NameAndType

    def arguments
      args = []
      args_node = elements.detect do |element|
        element.class == ArgumentsNode
      end

      if args_node
        args_node.elements.select do |element|
          element.class == ArgumentNode
        end.each do |arg|
          args << {
            :type => arg.Type,
            :name => arg.Name
          }
        end
      end
      args
    end
  end
  class FunctionBodyNode < BaseNode
  end

  class TypeNode < BaseNode
  end
  class NameNode < BaseNode
  end
  class ArgumentsNode < BaseNode
  end
  class ArgumentNode < BaseNode
    include NameAndType
  end
end