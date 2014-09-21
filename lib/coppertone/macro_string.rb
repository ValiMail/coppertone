require 'coppertone/macro_string/macro_parser'

module Coppertone
  # Instances of this class represent macro-strings, as defined by the
  # SPF specification (see section 7.1).
  #
  # MacroStrings should be evaluated ('expanded') in a particular context,
  # as the MacroString may use of a number of values available from the
  # context for interpolation.
  class MacroString
    attr_reader :macro_text
    def initialize(macro_text)
      @macro_text = macro_text
      macros
    end

    def macros
      @macros ||= MacroParser.new(macro_text).macros
    end

    def expand(context, request = nil)
      macros.map { |m| m.expand(context, request) }.join('')
    end

    def to_s
      macros.map(&:to_s).join('')
    end

    def context_dependent?
      macros.any? { |m| m.is_a?(Coppertone::MacroString::MacroExpand) }
    end

    def ==(other)
      return false unless other.instance_of? self.class
      macro_text == other.macro_text
    end
  end
end
