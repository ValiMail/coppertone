module Coppertone
  class Modifier  # rubocop:disable Style/Documentation
    class Unknown < Modifier
      def self.create(attributes)
        new(attributes)
      end

      def initialize(attributes)
        @macro_string = Coppertone::MacroString.new(attributes)
      rescue Coppertone::MacroStringParsingError
        raise Coppertone::InvalidModifierError
      end
    end
    register('unknown', Coppertone::Modifier::Unknown)
  end
end
