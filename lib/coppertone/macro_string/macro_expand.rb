require 'coppertone/error'

module Coppertone
  class MacroString
    # A internal class that represents a term in the MacroString that
    # may need to be expanded based on the SPF request context.  This
    # class validates against the Macro Definitions defined in section
    # 7.2, as well as against the set of delimiters, transformers, and
    # grammer defined in section 7.1.
    class MacroExpand
      MACRO_LETTER_CHAR_SET = '[slodiphcrtvSLODIPHCRTV]'
      PTR_MACRO_CHAR_SET = %w(p P)
      DELIMITER_CHAR_SET = '[\.\-\+\,\/\_\=]'
      VALID_BODY_REGEXP =
        /\A(#{MACRO_LETTER_CHAR_SET})(\d*)(r?)(#{DELIMITER_CHAR_SET}*)\z/

      attr_reader :macro_letter, :digit_transformers, :reverse,
                  :delimiter_regexp
      alias_method :reverse?, :reverse
      def initialize(s)
        matches = VALID_BODY_REGEXP.match(s)
        fail Coppertone::MacroStringParsingError if matches.nil?
        @macro_letter = matches[1]
        initialize_digit_transformers(matches[2])
        @reverse = (matches[3] == 'r')
        initialize_delimiter(matches[4])
        @body = s
      end

      def initialize_digit_transformers(raw_value)
        return unless raw_value
        @digit_transformers = raw_value.to_i if raw_value.length > 0
        return unless @digit_transformers
        fail Coppertone::MacroStringParsingError if @digit_transformers == 0
      end

      def ptr_macro?
        PTR_MACRO_CHAR_SET.include?(@macro_letter)
      end

      def expand_ptr(context, request)
        ptr =
          Coppertone::Utils::ValidatedDomainFinder
            .new(context, request, false).find(context.d)
        return 'unknown' unless ptr
        @macro_letter == 'P' ? ::Addressable::URI.encode_component(ptr) : ptr
      end

      def raw_value(context, request)
        ptr_macro? ? expand_ptr(context, request) : context.send(@macro_letter)
      end

      def expand(context, request = nil)
        labels = raw_value(context, request).split(@delimiter_regexp)
        labels.reverse! if @reverse
        labels = labels.last(@digit_transformers) if @digit_transformers
        labels.join(DEFAULT_DELIMITER)
      end

      def to_s
        "%{#{@body}}"
      end

      def ==(other)
        return false unless other.instance_of? self.class
        to_s == other.to_s
      end

      private

      DEFAULT_DELIMITER = '.'
      def initialize_delimiter(raw_delimiter)
        delimiter_chars =
          if raw_delimiter && raw_delimiter.length >= 1
            raw_delimiter
          else
            DEFAULT_DELIMITER
          end
        @delimiter_regexp =
          Regexp.new("[#{delimiter_chars}]")
      end
    end
  end
end
