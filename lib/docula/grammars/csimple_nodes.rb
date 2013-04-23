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
      elems = elements.select { |element| element.class == FunctionNode }
      if externs?
        elems.concat(externs(:functions)).flatten
      else
        elems
      end
    end
    def directives
      elems = elements.select { |element| element.class == DirectiveNode }
      if externs?
        elems.concat(externs(:directives)).flatten
      else
        elems
      end
    end
    def variables
      elems = elements.select { |element| element.class == VariableNode }
      structs = elements.select { |elem| elem.class == StructUnionNode && elem.Name? }

      elems.concat(structs).flatten! if structs
      elems.concat(externs(:variables)).flatten! if externs?

      elems
    end
    def docstrings
      elems = elements.select do |element|
        element.class == DocstringNode && element.file?
      end
      if externs?
        elems.concat(externs(:docstrings)).flatten
      else
        elems
      end
    end
    def typedefs
      elems = elements.select { |element| element.class == TypeDefNode }
      if externs?
        elems.concat(externs(:typedefs)).flatten
      else
        elems
      end
    end

    def structs_unions
      elems = elements.select do |element|
        element.class == StructUnionNode && !element.definition.nil?
      end
      if externs?
        elems.concat(externs(:structs_unions)).flatten
      else
        elems
      end
    end

    def externs(symb)
      if externs?
        elements.select { |element| element.class == ExternBlockNode }.map do |element|
          element.send(symb)
        end
      else
        nil
      end
    end

    def externs?
      !elements.detect { |element| element.class == ExternBlockNode }.nil?
    end
  end

  class DirectiveNode < BaseNode
    include Documentable

    def include?
      text_value.include? "#include"
    end

    def includes
      text_value.match(/#include\s+(?:<|")?(.*?)(?:>|")?/).captures.first
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

  class ExternBlockNode < StartNode
  end

  class StructUnionNode < BaseNode
    include Documentable

    def Type
      type = elements.detect { |elem| elem.class == NameNode }.text_value
      su = elements.detect { |elem| elem.class == SUNode }.text_value
      "#{su} #{type}".strip
    end

    def raw_type
      elements.detect { |elem| elem.class == NameNode }.text_value.strip
    end

    def struct_or_union
      elements.detect { |elem| elem.class == SUNode }.text_value
    end

    def Name
      if Name?
        elements.reverse_each.detect { |elem| elem.class == NameNode }.text_value
      end
    end

    def Name?
      elements.select { |elem| elem.class == NameNode }.count > 1
    end

    def definition
      elements.detect { |elem| elem.class == StructUnionDefinitionsNode }.definition
    end
  end

  module StructUnionDefinitionNode
    def function?
      self.class == FunctionNode
    end

    def variable?
      self.class == VariableNode
    end
  end
  class StructUnionDefinitionsNode < BaseNode
    def definition
      elements[1].elements.select { |elem| elem.kind_of? StructUnionDefinitionNode }
    end
  end

  class SUNode < BaseNode
    def struct?
      text_value == 'struct'
    end

    def union?
      text_value == 'union'
    end
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
