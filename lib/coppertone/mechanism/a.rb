require 'coppertone/mechanism/domain_spec_with_dual_cidr'
require 'coppertone/utils/ip_in_domain_checker'

module Coppertone
  class Mechanism # rubocop:disable Style/Documentation
    # Implements the A mechanism.
    class A < DomainSpecWithDualCidr
      def match_target_name(macro_context, request_context, target_name)
        Coppertone::Utils::IPInDomainChecker
          .new(macro_context, request_context)
          .check(target_name, ip_v4_cidr_length, ip_v6_cidr_length)
      end

      def self.label
        'a'
      end
    end
    register(Coppertone::Mechanism::A)
  end
end
