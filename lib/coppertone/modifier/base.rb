module Coppertone
  class Modifier  # rubocop:disable Style/Documentation
    class Base < Modifier
      attr_reader :domain_spec
      def initialize(attributes)
        fail InvalidModifierError if attributes.blank?
        @domain_spec = Coppertone::DomainSpec.new(attributes)
      rescue Coppertone::MacroStringParsingError
        raise Coppertone::InvalidModifierError
      end

      def target_name_from_domain_spec(macro_context, request_context)
        domain =
          domain_spec.expand(macro_context, request_context) if domain_spec
        Coppertone::Utils::DomainUtils.macro_expanded_domain(domain)
      end

      def ==(other)
        return false unless other.instance_of? self.class
        domain_spec == other.domain_spec
      end
    end
  end
end
