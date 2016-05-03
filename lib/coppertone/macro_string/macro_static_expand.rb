require 'coppertone/error'

module Coppertone
  class MacroString
    # A internal class that represents one of a few special terms in the macro
    # string definition.  These terms include a '%', but do not depend on the
    # SPF request context.
    class MacroStaticExpand
      def initialize(macro_text, s)
        @macro_text = macro_text
        @str = s
      end

      def expand(_context, _request = nil)
        @str
      end

      def to_s
        @macro_text
      end

      # Replaces '%%' in a macro string
      PERCENT_MACRO = new('%%'.freeze, '%'.freeze)

      # Replaces '%_' in a macro string
      SPACE_MACRO = new('%_'.freeze, ' '.freeze)

      # Replaces '%-' in a macro string
      URL_ENCODED_SPACE_MACRO = new('%-'.freeze, '%20'.freeze)

      SIMPLE_INTERPOLATED_MACRO_LETTERS = %w(% _ -).freeze
      def self.exists_for?(x)
        return false unless x && (x.length == 2) && (x[0] == '%')
        SIMPLE_INTERPOLATED_MACRO_LETTERS.include?(x[1])
      end

      def self.macro_for(x)
        raise Coppertone::MacroStringParsingError unless exists_for?(x)
        case x[1]
        when '%'
          PERCENT_MACRO
        when '_'
          SPACE_MACRO
        when '-'
          URL_ENCODED_SPACE_MACRO
        end
      end

      private_class_method :new
    end
  end
end
