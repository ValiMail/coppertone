module Coppertone
  # Represents an SPF request.
  class Request
    attr_reader :ip_as_s, :sender, :helo_domain, :options, :result
    attr_reader :helo_result, :mailfrom_result
    def initialize(ip_as_s, sender, helo_domain, options = {})
      @ip_as_s = ip_as_s
      @sender = sender
      @helo_domain = helo_domain
      @options = options
    end

    def authenticate
      process_helo || process_mailfrom || default_value
    end

    def process_helo
      check_spf_for_helo
      return nil if helo_result&.none?

      helo_result
    end

    def process_mailfrom
      check_spf_for_mailfrom
      return nil if mailfrom_result&.none?

      mailfrom_result
    end

    def default_value
      no_matching_record? ? Result.none : Result.neutral
    end

    def no_matching_record?
      helo_result.nil? && mailfrom_result.nil?
    end

    def request_context
      @request_context ||= RequestContext.new(options)
    end

    def helo_context
      MacroContext.new(helo_domain, ip_as_s, sender, helo_domain, options)
    end

    def mailfrom_context
      MacroContext.new(nil, ip_as_s, sender, helo_domain, options)
    end

    def spf_record(macro_context)
      RecordFinder.new(request_context.dns_client,
                       macro_context.domain).record
    end

    def spf_request(macro_context, record, identity)
      return Result.new(:none) if record.nil?

      r = RecordEvaluator.new(record).evaluate(macro_context, request_context)
      r.identity = identity
      r
    end

    private

    def check_spf_for_helo
      @helo_result = check_spf_for_context(helo_context, 'helo')
    end

    def check_spf_for_mailfrom
      @mailfrom_result = check_spf_for_context(mailfrom_context, 'mailfrom')
    end

    def check_spf_for_context(macro_context, identity)
      record = spf_record(macro_context)
      @result = spf_request(macro_context, record, identity) if record
    rescue DNSAdapter::Error => e
      Result.temperror(e.message)
    rescue Coppertone::TemperrorError => e
      Result.temperror(e.message)
    rescue Coppertone::PermerrorError => e
      Result.permerror(e.message)
    end
  end
end
