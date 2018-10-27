module Coppertone
  # Parses a record into terms
  class RecordTermParser
    VERSION_STR = 'v=spf1'.freeze
    RECORD_REGEXP = /\A#{VERSION_STR}(\s|\z)/i.freeze
    ALLOWED_CHARACTERS = /\A([\x21-\x7e ]+)\z/.freeze

    def self.record?(text)
      return false if text.blank?

      RECORD_REGEXP.match?(text.strip) ? true : false
    end

    attr_reader :text, :terms
    def initialize(text)
      raise RecordParsingError unless self.class.record?(text)
      raise RecordParsingError unless ALLOWED_CHARACTERS.match?(text)

      @text = text
      @terms = Coppertone::TermsParser.new(terms_segment).terms
    end

    def terms_segment
      text[VERSION_STR.length..-1].strip
    end
  end
end
