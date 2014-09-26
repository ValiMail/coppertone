module Coppertone
  # Represents an SPF record.  Includes class level methods for parsing
  # record from a text string.
  class Record
    attr_reader :text
    def initialize(raw_text)
      @terms = Coppertone::RecordTermParser.new(raw_text).terms
      normalize_terms
    end

    def self.record?(record_text)
      Coppertone::RecordTermParser.record?(record_text)
    end

    def normalize_terms
      find_redirect # Checks for duplicate redirect modifiers
      exp # Checks for duplicate exp modifiers
    end

    def directives
      @directives ||= @terms.select { |t| t.is_a?(Coppertone::Directive) }
    end

    def all_directive
      @all_directive ||= directives.find(&:all?)
    end

    def include_all?
      all_directive ? true : false
    end

    def default_result
      return Result.neutral unless all_directive
      Result.from_directive(all_directive)
    end

    def safe_to_include?
      include_all?
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

    KNOWN_MODS =
      [Coppertone::Modifier::Exp, Coppertone::Modifier::Redirect]
    def unknown_modifiers
      @unknown_modifiers ||=
        modifiers.select { |m| KNOWN_MODS.select { |k| m.is_a?(k) }.empty? }
    end

    def find_modifier(klass)
      arr = modifiers.select { |m| m.is_a?(klass) }
      fail DuplicateModifierError if arr.size > 1
      arr.first
    end

    def self.version_str
      Coppertone::RecordTermParser::VERSION_STR
    end

    def to_s
      "#{self.class.version_str} #{@terms.map(&:to_s).join(' ')}"
    end
  end
end
