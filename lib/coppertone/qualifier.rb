require 'coppertone/result'

module Coppertone
  # Instances of this class represent qualifiers, as defined by the
  # SPF specification (see section 4.6.1).
  #
  # There are only 4 qualifiers permitted by the specification, so
  # this class does not allow the creation of new instances.  These
  # fixed instances should be accessed through either the class level
  # constants or the qualifiers class method.
  class Qualifier
    @qualifier_hash = {}

    DEFAULT_QUALIFIER_TEXT = '+'.freeze
    def self.find_by_text(text)
      text = DEFAULT_QUALIFIER_TEXT if text.blank?
      @qualifier_hash[text]
    end

    def self.default_qualifier
      find_by_text(nil)
    end

    attr_reader :text, :result_code
    def initialize(text, result_code)
      @text = text
      @result_code = result_code
    end

    def default?
      text == DEFAULT_QUALIFIER_TEXT
    end

    def to_s
      text
    end

    PASS = new(DEFAULT_QUALIFIER_TEXT, Result::PASS)
    FAIL = new('-'.freeze, Result::FAIL)
    SOFTFAIL = new('~'.freeze, Result::SOFTFAIL)
    NEUTRAL = new('?'.freeze, Result::NEUTRAL)

    private_class_method :new

    def self.qualifiers
      [PASS, FAIL, SOFTFAIL, NEUTRAL]
    end

    qualifiers.each do |q|
      @qualifier_hash[q.text] = q
    end
  end
end
