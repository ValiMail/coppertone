module Coppertone
  class Mechanism  # rubocop:disable Style/Documentation
    # Implements the All mechanism.  To reduce unnecessary object creation, this
    # class is a singleton since all All mechanisms behave identically.
    class All < Mechanism
      SINGLETON = new
      private_class_method :new

      def self.create(attributes)
        fail InvalidMechanismError unless attributes.blank?
        SINGLETON
      end

      def self.instance
        SINGLETON
      end

      def match?(_macro_context, _request_context)
        true
      end
    end
    register('all', Coppertone::Mechanism::All)
  end
end
