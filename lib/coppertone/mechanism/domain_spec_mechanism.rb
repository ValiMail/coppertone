module Coppertone
  class Mechanism
    # Parent class for mechanisms that use a domain spec.
    class DomainSpecMechanism < Mechanism
      attr_reader :domain_spec

      def target_name_from_domain_spec(macro_context, request_context)
        if domain_spec
          domain =
            domain_spec.expand(macro_context, request_context)
        end
        Coppertone::Utils::DomainUtils.macro_expanded_domain(domain)
      end

      def trim_domain_spec(raw_domain_spec)
        return nil if raw_domain_spec.blank?

        raw_domain_spec[1..]
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

      def target_domain
        raise Coppertone::NeedsContextError if context_dependent?

        domain_spec.to_s
      end

      def ==(other)
        return false unless other.instance_of? self.class

        domain_spec == other.domain_spec
      end
      alias eql? ==

      def hash
        domain_spec.hash
      end
    end
  end
end
