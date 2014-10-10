require 'coppertone/mechanism/domain_spec_required'
require 'coppertone/mechanism/include_matcher'
require 'coppertone/record_finder'

module Coppertone
  class Mechanism  # rubocop:disable Style/Documentation
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

      def context_dependent_result?(request_context,
                                    macro_context =
                                      Coppertone::NullMacroContext.new)
        target_name =
          target_name_from_domain_spec(macro_context, request_context)
        included_record(request_context, target_name)
          .context_dependent_result?(request_context)
      end

      def self.label
        'include'
      end
    end
    register(Coppertone::Mechanism::Include)
  end
end
