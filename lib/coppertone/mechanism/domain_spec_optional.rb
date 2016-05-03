require 'coppertone/mechanism/domain_spec_mechanism'

module Coppertone
  class Mechanism
    # Parent class for mechanisms that use an optional domain spec.
    class DomainSpecOptional < DomainSpecMechanism
      def self.create(attributes)
        new(attributes)
      end

      def initialize(attributes)
        super(attributes)
        return if attributes.blank?
        raw_domain_spec = trim_domain_spec(attributes)
        @domain_spec = Coppertone::DomainSpec.new(raw_domain_spec)
      rescue Coppertone::MacroStringParsingError
        raise Coppertone::InvalidMechanismError
      end

      def match?(macro_context, request_context)
        request_context.register_dns_lookup_term
        target_name = generate_target_name(macro_context, request_context)
        if target_name
          match_target_name(macro_context, request_context, target_name)
        else
          handle_invalid_domain(macro_context, request_context)
        end
      end

      def generate_target_name(macro_context, request_context)
        if domain_spec
          target_name_from_domain_spec(macro_context, request_context)
        else
          macro_context.domain
        end
      end

      def handle_invalid_domain(_macro_context, _options)
        raise RecordParsingError
      end
    end
  end
end
