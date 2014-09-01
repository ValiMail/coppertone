require 'coppertone/mechanism/domain_spec_with_dual_cidr'

module Coppertone
  class Mechanism  # rubocop:disable Style/Documentation
    # Implements the MX mechanism.
    class MX < DomainSpecWithDualCidr
      def match_target_name(macro_context, request_context, target_name)
        mx_exchange_names = look_up_mx_exchanges(request_context, target_name)

        count = 0
        checker = ip_checker(macro_context, request_context)
        matched_record = mx_exchange_names.find do |mx|
          count += 1
          check_a_record_limit(request_context, count)
          checker.check(mx, ip_v4_cidr_length, ip_v6_cidr_length)
        end
        !matched_record.nil?
      end

      def ip_checker(macro_context, request_context)
        Coppertone::Utils::IPInDomainChecker.new(macro_context,
                                                 request_context)
      end

      def look_up_mx_exchanges(request_context, target_name)
        dns_client = request_context.dns_client
        dns_client.fetch_mx_records(target_name).map do |mx|
          mx[:exchange]
        end
      end

      def check_a_record_limit(request_context, count)
        limit = request_context.dns_lookups_per_mx_mechanism_limit
        return unless limit && count > limit
        fail Coppertone::MXLimitExceededError
      end
    end
    register('mx', Coppertone::Mechanism::MX)
  end
end
