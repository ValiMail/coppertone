module Coppertone
  # Parses a record into terms
  class RecordTermParser
    VERSION_STR =  'v=spf1'
    RECORD_REGEXP = /\A#{VERSION_STR}(\s|\z)/i
    ALLOWED_CHARACTERS = /\A([\x21-\x7e ]+)\z/

    def self.record?(text)
      return false if text.blank?
      RECORD_REGEXP.match(text.strip) ? true : false
    end

    attr_reader :text, :terms
    def initialize(text)
      fail RecordParsingError unless self.class.record?(text)
      fail RecordParsingError unless ALLOWED_CHARACTERS.match(text)
      @text = text
      @terms = Coppertone::TermsParser.new(terms_segment).terms
    end

    def terms_segment
      text[VERSION_STR.length..-1].strip
    end
  end
end
