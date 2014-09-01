module Coppertone
  class MacroString
    # A internal class that represents a fixed string in the macro template,
    # whose value will not depend on the SPF request context.
    class MacroLiteral
      def initialize(s)
        @str = s
      end

      def expand(_context, _request = nil)
        @str
      end

      def to_s
        @str
      end

      def ==(other)
        return false unless other.instance_of? self.class
        to_s == other.to_s
      end
    end
  end
end
