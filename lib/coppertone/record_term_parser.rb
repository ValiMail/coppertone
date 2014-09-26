module Coppertone
  class RecordTermParser
    VERSION_STR =  'v=spf1'
    RECORD_REGEXP = /\A#{VERSION_STR}(\s|\z)/i
    ALLOWED_CHARACTERS = /\A([\x21-\x7e ]+)\z/

    def self.record?(text)
      return false if text.blank?
      RECORD_REGEXP.match(text.strip) ? true : false
    end

    attr_reader :terms
    def initialize(text)
      fail RecordParsingError unless self.class.record?(text)
      fail RecordParsingError unless ALLOWED_CHARACTERS.match(text)
      @terms = term_tokens(text).map { |token| parse_token(token) }
    end

    def term_tokens(text)
      text_without_prefix = text[VERSION_STR.length..-1]
      text_without_prefix.strip.split(/ /).select { |s| !s.blank? }
    end

    def parse_token(token)
      term = Term.build_from_token(token)
      fail RecordParsingError unless term
      term
    end
  end
end
