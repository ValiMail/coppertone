require 'active_support/core_ext/module/delegation'
require 'coppertone/dns/resolv_client'

module Coppertone
  # A container for information that should span the lifetime of
  # an SPF check.  This include the DNS client, the locale used
  # for error messages, limits for DNS requests of different
  # types, and limiters that ensure those limits are not exceeded
  # across the lifetime of the request.
  class RequestContext
    def initialize(options = {})
      @options = (options || {}).dup
    end

    def register_dns_lookup_term
      dns_lookup_term_count_limiter.increment!
    end

    def register_void_dns_result
      void_dns_result_count_limiter.increment!
    end

    def dns_lookups_per_mx_mechanism_limit
      config_value(:dns_lookups_per_mx_mechanism_limit)
    end

    def dns_lookups_per_ptr_mechanism_limit
      config_value(:dns_lookups_per_ptr_mechanism_limit)
    end

    def message_locale
      config_value(:message_locale)
    end

    def dns_client
      @dns_client ||=
        if @options[:dns_client]
          @options[:dns_client]
        elsif @options[:dns_client_class]
          @options[:dns_client_class].new
        elsif Coppertone.config.dns_client_class
          Coppertone.config.dns_client_class.new
        else
          Coppertone::DNS::ResolvClient.new
        end
    end

    private

    def dns_lookup_term_count_limiter
      limit = config_value(:terms_requiring_dns_lookup_limit)
      @dns_lookup_term_count_limiter ||=
        Coppertone::RequestCountLimiter.new(limit, 'DNS lookup term')
    end

    def void_dns_result_count_limiter
      limit = config_value(:void_dns_result_limit)
      @void_dns_result_count_limiter ||=
        Coppertone::RequestCountLimiter.new(limit, 'DNS lookup term')
    end

    def config_value(k)
      return @options[k] if @options.key?(k)
      Coppertone.config.send(k)
    end
  end
end
