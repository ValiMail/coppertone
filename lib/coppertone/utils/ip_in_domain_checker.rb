module Coppertone
  module Utils
    # Checks the IP address from the request against an A or AAAA record
    # for a domain.  Takes optional CIDR arguments so the match can
    # check subnets
    class IPInDomainChecker
      def initialize(macro_context, request_context)
        @macro_context = macro_context
        @request_context = request_context
      end

      def check(domain_name,
                ip_v4_cidr_length = 32,
                ip_v6_cidr_length = 128)
        cidr_length = ip_v6? ? ip_v6_cidr_length : ip_v4_cidr_length
        networks = ip_networks(domain_name, cidr_length)
        @request_context.register_void_dns_result if networks.empty?

        matching_network =
          networks.find do |network|
            network.include?(ip)
          end
        !matching_network.nil?
      end

      def ip_v6?
        @macro_context.original_ipv6?
      end

      def ip
        ip_v6? ? @macro_context.ip_v6 : @macro_context.ip_v4
      end

      def ip_networks(domain_name, cidr_length)
        ip_records =
          if ip_v6?
            dns_client.fetch_aaaa_records(domain_name)
          else
            dns_client.fetch_a_records(domain_name)
          end
        filtered_records(ip_records, cidr_length)
      end

      def dns_client
        @request_context.dns_client
      end

      def filtered_records(recs, cidr_length)
        ips = recs.map do |r|
          IPAddr.new(r[:address]).mask(cidr_length.to_i)
        end
        ips.compact
      end
    end
  end
end
