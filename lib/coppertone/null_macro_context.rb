module Coppertone
  # A context used to evaluate records, directives, and modifiers that
  # do not have contextual dependence.
  class NullMacroContext
    RESERVED_REGEXP = Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
    %w(s l o d i p v h c r t).each do |m|
      define_method(m.upcase) do
        raise ArgumentError
      end

      define_method(m) do
        raise ArgumentError
      end
    end

    def with_domain(_new_domain)
      self
    end

    NULL_CONTEXT = new
  end
end
