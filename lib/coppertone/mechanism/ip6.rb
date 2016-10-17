require 'coppertone/mechanism/ip_mechanism'

module Coppertone
  class Mechanism
    # Implements the ip6 mechanism.
    class IP6 < IPMechanism
      def ip_for_match(macro_context)
        macro_context.ip_v6
      end

      def self.label
        'ip6'
      end
    end
    register(Coppertone::Mechanism::IP6)
  end
end
