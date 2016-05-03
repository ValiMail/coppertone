require 'coppertone/record_evaluator'

module Coppertone
  class Mechanism
    # Implements the include mechanism.
    class IncludeMatcher
      # Evaluates records that are referenced via an include
      class IncludeRecordEvaluator < Coppertone::RecordEvaluator
        def evaluate_fail_result(result, _m, _r)
          result
        end

        def evaluate_none_result(result, m, r)
          new_result = super
          return new_result unless new_result.none?
          raise Coppertone::NoneIncludeResultError
        end
      end

      attr_reader :record
      def initialize(record)
        @record = record
      end

      def match?(macro_context, request_context)
        raise Coppertone::NoneIncludeResultError if record.nil?
        record_result =
          IncludeRecordEvaluator.new(record)
                                .evaluate(macro_context, request_context)
        record_result.pass?
      end
    end
  end
end
