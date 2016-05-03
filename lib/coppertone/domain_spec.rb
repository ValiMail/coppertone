require 'coppertone/macro_string'
require 'coppertone/utils'

module Coppertone
  # A domain spec, as defined in the SPF specification.
  class DomainSpec < MacroString
    def initialize(s)
      begin
        super
      rescue Coppertone::MacroStringParsingError
        raise Coppertone::DomainSpecParsingError
      end
      validate_domain_spec_restrictions
    end

    def validate_domain_spec_restrictions
      return if only_allowed_macros? && ends_in_allowed_term?
      raise Coppertone::DomainSpecParsingError
    end

    EXP_ONLY_MACRO_LETTERS = %w(c r t).freeze
    def only_allowed_macros?
      @macros.select { |m| m.is_a?(Coppertone::MacroString::MacroExpand) }
             .none? { |m| EXP_ONLY_MACRO_LETTERS.include?(m.macro_letter) }
    end

    def ends_in_allowed_term?
      lm = @macros.last
      return true unless lm
      return false if lm.is_a?(Coppertone::MacroString::MacroStaticExpand)
      return true if lm.is_a?(Coppertone::MacroString::MacroExpand)
      ends_with_top_label?
    end

    def ends_with_top_label?
      ends_with = @macros.last.to_s
      ends_with = ends_with[0..-2] if ends_with[-1] == '.'
      _, match, tail = ends_with.rpartition('.')
      return false if match.blank?
      hostname = Coppertone::Utils::DomainUtils.valid_hostname_label?(tail)
      return false unless hostname
      true
    end
  end
end
