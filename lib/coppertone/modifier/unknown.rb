module Coppertone
  class Modifier
    # Object representing unknown modifiers - those that aren't explicitly
    # defined by the SPF spec
    class Unknown < Modifier
      attr_reader :label

      def initialize(label, attributes)
        super(attributes)
        @label = label
        @macro_string = Coppertone::MacroString.new(attributes)
      rescue Coppertone::MacroStringParsingError
        raise Coppertone::InvalidModifierError
      end

      def context_dependent?
        false
      end

      def includes_ptr?
        false
      end
    end
  end
end
