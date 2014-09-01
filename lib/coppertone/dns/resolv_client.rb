require 'resolv'
require 'resolv/dns/resource/in/spf'

module Coppertone
  module DNS
    # An adapter client for the internal Resolv DNS client.
    class ResolvClient
      def fetch_a_records(domain)
        fetch_a_type_records(domain, 'A')
      end

      def fetch_aaaa_records(domain)
        fetch_a_type_records(domain, 'AAAA')
      end

      def fetch_mx_records(domain)
        fetch_records(domain, 'MX') do |record|
          {
            type: 'MX',
            exchange: record.exchange.to_s
          }
        end
      end

      def fetch_ptr_records(arpa_address)
        fetch_records(arpa_address, 'PTR') do |record|
          {
            type: 'PTR',
            name: record.name.to_s
          }
        end
      end

      def fetch_txt_records(domain)
        fetch_txt_type_records(domain, 'TXT')
      end

      def fetch_spf_records(domain)
        fetch_txt_type_records(domain, 'SPF')
      end

      private

      def fetch_a_type_records(domain, type)
        fetch_records(domain, type) do |record|
          {
            type: type,
            address: record.address.to_s
          }
        end
      end

      def fetch_txt_type_records(domain, type)
        fetch_records(domain, type) do |record|
          {
            type: type,
            # Use strings.join('') to avoid JRuby issue where
            # data only returns the first string
            text: record.strings.join('')
          }
        end
      end

      def fetch_records(domain, type, &block)
        records = dns_lookup(domain, type)
        records.map(&block)
      end

      TRAILING_DOT_REGEXP = /\.\z/
      def normalize_domain(domain)
        (domain.sub(TRAILING_DOT_REGEXP, '') || domain).downcase
      end

      def dns_lookup(domain, rr_type)
        domain = normalize_domain(domain)
        resources = getresources(domain, rr_type)

        unless resources
          fail Coppertone::DNS::Error,
               "Unknown error on DNS '#{rr_type}' lookup of '#{domain}'"
        end

        resources
      end

      def getresources(domain, rr_type)
        rr_class = self.class.type_class(rr_type)
        dns_resolver.getresources(domain, rr_class)
      rescue Resolv::ResolvTimeout
        raise Coppertone::DNS::TimeoutError,
              "Time-out on DNS '#{rr_type}' lookup of '#{domain}'"
      rescue Resolv::ResolvError
        raise Coppertone::DNS::Error, "Error on DNS lookup of '#{domain}'"
      end

      SUPPORTED_RR_TYPES = %w(A AAAA MX PTR TXT SPF)
      def self.type_class(rr_type)
        if SUPPORTED_RR_TYPES.include?(rr_type)
          Resolv::DNS::Resource::IN.const_get(rr_type)
        else
          fail ArgumentError, "Unknown RR type: #{rr_type}"
        end
      end

      def dns_resolver
        @dns_resolver ||= Resolv::DNS.new
      end
    end
  end
end
