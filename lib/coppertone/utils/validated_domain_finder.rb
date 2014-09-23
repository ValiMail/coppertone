module Coppertone
  module Utils  # rubocop:disable Style/Documentation
    # A class used to find validated domains as defined in
    # section 5.5 of the RFC.
    class ValidatedDomainFinder
      attr_reader :subdomain_only
      def initialize(macro_context, request_context, subdomain_only = true)
        @mc = macro_context
        @request_context = request_context
        @subdomain_only = subdomain_only
      end

      def find(target_name)
        ip = @mc.original_ipv6? ? @mc.ip_v6 : @mc.ip_v4
        ptr_names = fetch_ptr_names(ip)
        ip_checker = IPInDomainChecker.new(@mc, @request_context)
        ptr_names.find { |n| ptr_record_matches?(ip_checker, target_name, n) }
      end

      def fetch_ptr_names(ip)
        dns_client = @request_context.dns_client
        names = dns_client.fetch_ptr_records(ip.reverse).map do |ptr|
          ptr[:name]
        end
        record_limit =
          @request_context.dns_lookups_per_ptr_mechanism_limit
        record_limit ? names.slice(0, record_limit) : names
      end

      def ptr_record_matches?(ip_checker,
                              target_name, ptr_name)
        is_candidate = !subdomain_only ||
                       DomainUtils.subdomain_or_same?(ptr_name, target_name)
        is_candidate && ip_checker.check(ptr_name)
      rescue Coppertone::DNS::Error
        # If a DNS error occurs when looking up a domain, treat it
        # as a non match
        false
      end
    end
  end
end
