module Coppertone
  # A helper class for finding SPF records for a redirect modifier.
  class RedirectRecordFinder
    attr_reader :redirect, :macro_context, :request_context
    def initialize(redirect, macro_context, request_context)
      @redirect = redirect
      @macro_context = macro_context
      @request_context = request_context
    end

    def target
      @target ||= redirect.evaluate(macro_context, request_context)
    end

    def record
      return unless target
      @record ||= RecordFinder.new(request_context.dns_client, target).record
    end
  end
end
