require 'coppertone/mechanism/ip_mechanism'

module Coppertone
  class Mechanism  # rubocop:disable Style/Documentation
    # Implements the ip4 mechanism.
    class IP4 < IPMechanism
      def ip_for_match(macro_context)
        macro_context.ip_v4
      end
    end
    register('ip4', Coppertone::Mechanism::IP4)
  end
end
