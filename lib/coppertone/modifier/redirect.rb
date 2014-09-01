require 'coppertone/modifier/base'

module Coppertone
  class Modifier  # rubocop:disable Style/Documentation
    class Redirect < Coppertone::Modifier::Base
      def self.create(attributes)
        new(attributes)
      end

      def evaluate(macro_context, request_context)
        request_context.register_dns_lookup_term
        target_name_from_domain_spec(macro_context, request_context)
      end
    end
    register('redirect', Coppertone::Modifier::Redirect)
  end
end
