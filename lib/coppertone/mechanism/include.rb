require 'coppertone/mechanism/domain_spec_required'
require 'coppertone/mechanism/include_matcher'
require 'coppertone/record_finder'

module Coppertone
  class Mechanism  # rubocop:disable Style/Documentation
    # Implements the include mechanism.
    class Include < DomainSpecRequired
      def match_target_name(macro_context, request_context, target_name)
        context_for_include = macro_context.with_domain(target_name)
        record =
          RecordFinder.new(request_context.dns_client, target_name).record
        IncludeMatcher.new(record).match?(context_for_include, request_context)
      end

      def self.label
        'include'
      end
    end
    register(Coppertone::Mechanism::Include)
  end
end
