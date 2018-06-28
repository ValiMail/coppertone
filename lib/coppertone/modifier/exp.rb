require 'coppertone/modifier/base'

module Coppertone
  class Modifier
    # Exp modifier - specifying a message to be returned in case of failure
    class Exp < Coppertone::Modifier::Base
      def self.create(attributes)
        new(attributes)
      end

      ASCII_REGEXP = /\A[[:ascii:]]*\z/
      def evaluate(macro_context, request_context)
        target_name =
          target_name_from_domain_spec(macro_context, request_context)
        return nil unless target_name
        macro_string = lookup_macro_string(target_name, request_context)
        return nil unless macro_string
        expanded = macro_string.expand(macro_context, request_context)
        return nil unless ASCII_REGEXP.match?(expanded)
        expanded
      rescue DNSAdapter::Error
        nil
      end

      def lookup_macro_string(target_name, request_context)
        records =
          request_context.dns_client.fetch_txt_records(target_name)
        return nil if records.empty?
        return nil if records.size > 1
        MacroString.new(records.first[:text])
      end

      def self.label
        'exp'
      end
    end
    register(Coppertone::Modifier::Exp)
  end
end
