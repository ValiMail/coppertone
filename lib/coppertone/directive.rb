require 'coppertone/mechanism'
require 'coppertone/qualifier'

module Coppertone
  # Instances of this class represent directive terms, as defined by the
  # SPF specification (see section 4.6.1).
  class Directive
    attr_reader :qualifier, :mechanism
    def initialize(qualifier, mechanism)
      @qualifier = qualifier
      @mechanism = mechanism
    end

    def evaluate(context, options)
      code =
        if mechanism.match?(context, options)
          qualifier.result_code
        else
          Result::NONE
        end
      Coppertone::Result.from_directive(self, code)
    end

    DIRECTIVE_REGEXP = /\A([\+\-\~\?]?)([a-zA-Z0-9]*)((:?)\S*)\z/
    def self.matching_term(text)
      return nil if text.include?('=')
      matches = DIRECTIVE_REGEXP.match(text)
      return nil unless matches
      qualifier_txt = matches[1]
      mechanism_type = matches[2].downcase
      attributes = matches[3]
      qualifier = Qualifier.find_by_text(qualifier_txt)
      mechanism = Mechanism.build(mechanism_type, attributes)
      return nil unless qualifier && mechanism
      new(qualifier, mechanism)
    end
  end
end
