module Coppertone
  # A helper class for finding SPF records for a domain.
  class RecordEvaluator
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def evaluate(macro_context, request_context)
      result = directive_result(macro_context, request_context)
      return result unless result.none? || result.fail?

      if result.fail?
        evaluate_fail_result(result, macro_context, request_context)
      else
        # Evaluate redirect
        evaluate_none_result(result, macro_context, request_context)
      end
    end

    def directive_result(macro_context, request_context)
      record.directives.reduce(Result.none) do |memo, d|
        memo.none? ? d.evaluate(macro_context, request_context) : memo
      end
    end

    def evaluate_fail_result(result, macro_context, request_context)
      add_exp_to_result(result, macro_context, request_context)
    end

    def add_exp_to_result(result, macro_context, request_context)
      result = add_default_exp(result)
      return result unless record.exp

      computed_exp = record.exp.evaluate(macro_context, request_context)
      result.explanation = computed_exp if computed_exp
      result
    rescue Coppertone::Error
      result
    end

    def add_default_exp(result)
      result.explanation = Coppertone.config.default_explanation
      result
    end

    def follow_redirect?
      # Ignore the redirect if there's an all
      # mechanism in the record
      record.redirect && !record.include_all?
    end

    def evaluate_none_result(result, macro_context, request_context)
      return result unless follow_redirect?

      finder =
        Coppertone::RedirectRecordFinder.new(record.redirect, macro_context,
                                             request_context)
      raise InvalidRedirectError unless finder.target && finder.record

      rc = macro_context.with_domain(finder.target)
      RecordEvaluator.new(finder.record).evaluate(rc, request_context)
    end
  end
end
