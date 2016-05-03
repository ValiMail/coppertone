module Coppertone
  class Modifier
    # Base class including logic common to modifiers
    class Base < Modifier
      attr_reader :domain_spec
      def initialize(attributes)
        super(attributes)
        raise InvalidModifierError if attributes.blank?
        @domain_spec = Coppertone::DomainSpec.new(attributes)
      rescue Coppertone::MacroStringParsingError
        raise Coppertone::InvalidModifierError
      end

      def target_name_from_domain_spec(macro_context, request_context)
        domain =
          domain_spec.expand(macro_context, request_context) if domain_spec
        Coppertone::Utils::DomainUtils.macro_expanded_domain(domain)
      end

      def context_dependent?
        domain_spec.context_dependent?
      end

      def includes_ptr?
        domain_spec.includes_ptr?
      end

      def ==(other)
        return false unless other.instance_of? self.class
        domain_spec == other.domain_spec
      end
    end
  end
end
