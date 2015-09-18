module Coppertone
  # A helper class for finding SPF records for a domain.
  class RecordFinder
    attr_reader :dns_client, :domain
    def initialize(dns_client, domain)
      @dns_client = dns_client
      @domain = domain
    end

    def record
      @record ||=
        begin
          validate_txt_records
          spf_dns_record = txt_records.first
          return nil unless spf_dns_record
          Record.new(spf_dns_record)
        end
    end

    def txt_records
      @txt_records ||=
        begin
          if Coppertone::Utils::DomainUtils.valid?(domain)
            dns_client.fetch_txt_records(domain).map { |r| r[:text] }
            .select { |r| Record.record?(r) }
          else
            []
          end
        end
    end

    def validate_txt_records
      fail AmbiguousSpfRecordError if txt_records.size > 1
    end
  end
end
