module Coppertone
  class Modifier  # rubocop:disable Style/Documentation
    class Unknown < Modifier
      def self.create(attributes)
        new(attributes)
      end

      def initialize(attributes)
        super(attributes)
        @macro_string = Coppertone::MacroString.new(attributes)
      rescue Coppertone::MacroStringParsingError
        raise Coppertone::InvalidModifierError
      end

      def self.label
        'unknown'
      end
    end
    register(Coppertone::Modifier::Unknown)
  end
end
