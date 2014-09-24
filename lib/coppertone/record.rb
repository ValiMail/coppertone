module Coppertone
  # Represents an SPF record.  Includes class level methods for parsing
  # record from a text string.
  class Record
    VERSION_STR =  'v=spf1'
    RECORD_REGEXP = /\A#{VERSION_STR}(\s|\z)/i
    ALLOWED_CHARACTERS = /\A([\x21-\x7e ]+)\z/

    attr_reader :text
    def initialize(raw_text)
      fail RecordParsingError if raw_text.blank?
      fail RecordParsingError unless self.class.record?(raw_text)
      fail RecordParsingError unless ALLOWED_CHARACTERS.match(raw_text)
      @text = raw_text.dup
      validate_and_parse
    end

    def self.record?(record_text)
      return false if record_text.blank?
      RECORD_REGEXP.match(record_text.strip) ? true : false
    end

    def self.parse(text)
      return nil unless record?(text)
      new(text)
    end

    def validate_and_parse
      text_without_prefix = text[VERSION_STR.length..-1]
      @term_tokens =
        text_without_prefix.strip.split(/ /).select { |s| !s.blank? }
      parse_terms
    end

    def parse_terms
      @terms = []
      @term_tokens.each do |token|
        term = Term.build_from_token(token)
        fail RecordParsingError,
             "Could not parse record with #{text}" unless term
        @terms << term
      end
      normalize_terms
    end

    def normalize_terms
      find_redirect # Checks for duplicate redirect modifiers
      exp # Checks for duplicate exp modifiers
    end

    def directives
      @directives ||= @terms.select { |t| t.is_a?(Coppertone::Directive) }
    end

    def include_all?
      directives.any?(&:all?)
    end

    def modifiers
      @modifiers ||= @terms.select { |t| t.is_a?(Coppertone::Modifier) }
    end

    def find_redirect
      find_modifier(Coppertone::Modifier::Redirect)
    end

    def redirect
      @redirect ||= find_redirect
    end

    def exp
      @exp ||= find_modifier(Coppertone::Modifier::Exp)
    end

    KNOWN_MODIFIERS =
      [Coppertone::Modifier::Exp, Coppertone::Modifier::Redirect]
    def unknown_modifiers
      @unknown_modifiers ||=
        modifiers.select { |m| KNOWN_MODIFIERS.select { |k| m.is_a?(k) }.empty? }
    end

    def find_modifier(klass)
      arr = modifiers.select { |m| m.is_a?(klass) }
      fail DuplicateModifierError if arr.size > 1
      arr.first
    end
  end
end
