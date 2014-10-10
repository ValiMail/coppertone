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
      if mechanism.match?(context, options)
        Coppertone::Result.from_directive(self)
      else
        Result.none
      end
    end

    def context_dependent?
      mechanism.context_dependent?
    end

    def all?
      mechanism.is_a?(Coppertone::Mechanism::All)
    end

    def to_s
      mechanism_s = mechanism.to_s
      qualifier.default? ? mechanism_s : "#{qualifier}#{mechanism_s}"
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
