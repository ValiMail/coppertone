require 'coppertone/mechanism/domain_spec_required'

module Coppertone
  class Mechanism  # rubocop:disable Style/Documentation
    # Implements the exists mechanism.
    class Exists < DomainSpecRequired
      def match_target_name(_macro_context, request_context, target_name)
        records = request_context.dns_client.fetch_a_records(target_name)
        records.any?
      end
    end
    register('exists', Coppertone::Mechanism::Exists)
  end
end
