module Coppertone
  class Mechanism
    # Parses a CIDR parameter subject to a max_val (32 for IPv4, 128 for IPv6)
    class CidrParser
      def self.parse(raw_length, max_val)
        return if raw_length.blank?

        length_as_i = raw_length.to_i
        raise Coppertone::InvalidMechanismError if length_as_i.negative? || length_as_i > max_val

        length_as_i
      end
    end
  end
end
