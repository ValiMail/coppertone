require 'coppertone/macro_string/macro_literal'
require 'coppertone/macro_string/macro_expand'
require 'coppertone/macro_string/macro_static_expand'

module Coppertone
  class MacroString
    # A internal class that parses the macro string template into
    # an object that can later be evaluated (or 'expanded')
    # in the context of a particular SPF check.
    class MacroParser
      attr_reader :macros
      def initialize(s)
        @s = s.dup
        @macros = []
        parse_macro_array
      end

      def parse_macro_array
        while @s && @s.length > 0
          if starting_macro?
            parse_interpolated_macro
          else
            parse_macro_literal
          end
        end
      end

      def starting_macro?
        @s && @s.length >= 1 && (@s[0] == '%')
      end

      def parse_contextual_interpolated_macro
        fail MacroStringParsingError unless @s[1] == '{'
        closing_index = @s.index('}')
        fail MacroStringParsingError unless closing_index
        interpolated_body = @s[2, closing_index - 2]
        @macros << MacroExpand.new(interpolated_body)
        @s = @s[(closing_index + 1)..-1]
      end

      SIMPLE_MACRO_LETTERS = %w(% _ -)
      def parse_interpolated_macro
        fail MacroStringParsingError if @s.length == 1
        macro_code = @s[0, 2]
        if MacroStaticExpand.exists_for?(macro_code)
          @macros << MacroStaticExpand.macro_for(macro_code)
          @s = @s[2..-1]
        else
          parse_contextual_interpolated_macro
        end
      end

      def parse_macro_literal
        new_idx = @s.index('%')
        new_idx ||= @s.length
        @macros << MacroLiteral.new(@s[0, new_idx])
        @s = @s[new_idx..-1]
        new_idx
      end
    end
  end
end
