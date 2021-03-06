require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'

# A library for evaluating, creating, and analyzing SPF records
module Coppertone
  class << self
    def config
      @config ||= OpenStruct.new(defaults)
    end

    def defaults
      {
        hostname: nil,
        message_locale: 'en',
        terms_requiring_dns_lookup_limit: 10,
        dns_lookups_per_mx_mechanism_limit: 10,
        dns_lookups_per_ptr_mechanism_limit: 10,
        void_dns_result_limit: 2,
        dns_client_class: nil,
        default_explanation: 'DEFAULT'
      }
    end

    # Used for testing.
    def reset_config
      @config = nil
    end
  end
end

require 'dns_adapter'
require 'coppertone/version'
require 'coppertone/utils'
require 'coppertone/error'
require 'coppertone/request_count_limiter'
require 'coppertone/sender_identity'
require 'coppertone/ip_address_wrapper'
require 'coppertone/macro_context'
require 'coppertone/null_macro_context'
require 'coppertone/macro_string'
require 'coppertone/request_context'
require 'coppertone/domain_spec'
require 'coppertone/directive'
require 'coppertone/modifier'
require 'coppertone/term'
require 'coppertone/terms_parser'
require 'coppertone/record_term_parser'
require 'coppertone/record'
require 'coppertone/record_evaluator'
require 'coppertone/record_finder'
require 'coppertone/redirect_record_finder'
require 'coppertone/request'
require 'coppertone/spf_service'
