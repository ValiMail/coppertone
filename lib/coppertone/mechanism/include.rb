require 'coppertone/mechanism/domain_spec_required'
require 'coppertone/mechanism/include_matcher'
require 'coppertone/record_finder'

module Coppertone
  class Mechanism
    # Implements the include mechanism.
    class Include < DomainSpecRequired
      def match_target_name(macro_context, request_context, target_name)
        record = included_record(request_context, target_name)
        IncludeMatcher.new(record)
                      .match?(context_for_include(macro_context, target_name),
                              request_context)
      end

      def context_for_include(macro_context, target_name)
        macro_context.with_domain(target_name)
      end

      def included_record(request_context, target_name)
        RecordFinder.new(request_context.dns_client, target_name).record
      end

      def self.label
        'include'
      end

      def self.requires_initial_colon?
        true
      end
    end
    register(Coppertone::Mechanism::Include)
  end
end
