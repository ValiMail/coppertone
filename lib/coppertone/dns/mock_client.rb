require 'coppertone/error'

module Coppertone
  module DNS
    # A mock client for use in tests.
    class MockClient
      def initialize(zone_data)
        @zone_data = {}
        zone_data.each do |k, v|
          @zone_data[k.downcase] = v.dup
        end
      end

      def fetch_a_records(domain)
        fetch_records(domain, 'A')
      end

      def fetch_aaaa_records(domain)
        fetch_records(domain, 'AAAA')
      end

      def fetch_mx_records(domain)
        fetch_records(domain, 'MX')
      end

      def fetch_ptr_records(arpa_address)
        fetch_records(arpa_address, 'PTR')
      end

      def fetch_txt_records(domain)
        fetch_records(domain, 'TXT')
      end

      def fetch_spf_records(domain)
        fetch_records(domain, 'SPF')
      end

      def fetch_records(domain, type)
        record_set = find_records_for_domain(domain)
        return [] if record_set.empty?
        records = records_for_type(record_set, type)
        if records.empty?
          check_for_timeout(record_set)
        else
          formatted_records(records, type)
        end
      end

      private

      def normalize_domain(domain)
        return if domain.blank?
        domain = domain[0...-1] if domain[domain.length - 1] == '.'
        domain.downcase
      end

      def find_records_for_domain(domain)
        return [] if domain.blank?
        @zone_data[normalize_domain(domain)] || []
      end

      def records_for_type(record_set, type)
        record_set.select do |r|
          r.is_a?(Hash) && r[type] && r[type] != 'NONE'
        end
      end

      TIMEOUT = 'TIMEOUT'
      def check_for_timeout(record_set)
        return [] if record_set.select { |r| r == TIMEOUT }.empty?
        fail Coppertone::DNS::TimeoutError
      end

      RECORD_TYPE_TO_ATTR_NAME_MAP = {
        'A' => :address,
        'AAAA' => :address,
        'MX' => :exchange,
        'PTR' => :name,
        'SPF' => :text,
        'TXT' => :text
      }

      def formatted_records(records, type)
        records.map do |r|
          val = r[type]
          fail Coppertone::DNS::TimeoutError if val == TIMEOUT
          val = normalize_value(val, type)
          {
            type: type,
            RECORD_TYPE_TO_ATTR_NAME_MAP[type] => val
          }
        end
      end

      def normalize_value(value, type)
        if type == 'MX' && value.is_a?(Array)
          value.last
        elsif (type == 'TXT' || type == 'SPF') && value.is_a?(Array)
          value.join('')
        else
          value
        end
      end
    end
  end
end
