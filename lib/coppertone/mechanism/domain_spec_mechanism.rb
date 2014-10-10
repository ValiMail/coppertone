module Coppertone
  class Mechanism  # rubocop:disable Style/Documentation
    class DomainSpecMechanism < Mechanism
      attr_reader :domain_spec

      def target_name_from_domain_spec(macro_context, request_context)
        domain =
          domain_spec.expand(macro_context, request_context) if domain_spec
        Coppertone::Utils::DomainUtils.macro_expanded_domain(domain)
      end

      def trim_domain_spec(raw_domain_spec)
        return nil if raw_domain_spec.blank?
        raw_domain_spec[1..-1]
      end

      def self.dns_lookup_term?
        true
      end

      def context_dependent?
        return true unless domain_spec
        domain_spec.context_dependent?
      end

      def includes_ptr?
        return false unless domain_spec
        domain_spec.includes_ptr?
      end
    end
  end
end
