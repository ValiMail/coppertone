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

    def dns_lookup_term_count
      @dns_lookup_term_count ||=
        begin
          base = redirect.nil? ? 0 : 1
          base + directives.count(&:dns_lookup_term?)
        end
    end

    def includes
      @includes ||=
        begin
          directives.select do |d|
            d.mechanism.is_a?(Coppertone::Mechanism::Include)
          end
        end
    end

    def modifiers
      @modifiers ||= @terms.select { |t| t.is_a?(Coppertone::Modifier) }
    end

    def redirect
      @redirect ||= find_redirect
    end

    def redirect_with_directives?
      redirect && directives.any?
    end

    def netblock_mechanisms
      @netblock_mechanisms ||=
        directives.select do |d|
          d.mechanism.is_a?(Coppertone::Mechanism::IPMechanism)
        end
    end

    def netblocks_only?
      return false if redirect

      directives.reject(&:all?).reject do |d|
        d.mechanism.is_a?(Coppertone::Mechanism::IPMechanism)
      end.empty?
    end

    def context_dependent_evaluation?
      return true if directives.any?(&:context_dependent?)

      redirect&.context_dependent?
    end

    def exp
      @exp ||= find_modifier(Coppertone::Modifier::Exp)
    end

    def context_dependent_explanation?
      exp&.context_dependent?
    end

    KNOWN_MODS =
      [Coppertone::Modifier::Exp, Coppertone::Modifier::Redirect].freeze
    def unknown_modifiers
      @unknown_modifiers ||=
        modifiers.select { |m| KNOWN_MODS.select { |k| m.is_a?(k) }.empty? }
    end

    def find_modifier(klass)
      arr = modifiers.select { |m| m.is_a?(klass) }
      raise DuplicateModifierError if arr.size > 1

      arr.first
    end

    def find_redirect
      find_modifier(Coppertone::Modifier::Redirect)
    end

    def self.version_str
      Coppertone::RecordTermParser::VERSION_STR
    end

    def to_s
      "#{self.class.version_str} #{@terms.map(&:to_s).join(' ')}"
    end
  end
end
