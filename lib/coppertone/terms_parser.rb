module Coppertone
  # Parses a un-prefixed string into terms
  class TermsParser
    attr_reader :text
    def initialize(text)
      @text = text
    end

    def terms
      tokens.map { |token| parse_token(token) }
    end

    def tokens
      text.split(/ /).select { |s| !s.blank? }
    end

    def parse_token(token)
      term = Term.build_from_token(token)
      raise RecordParsingError unless term
      term
    end
  end
end
