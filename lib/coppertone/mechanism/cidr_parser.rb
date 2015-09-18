module Coppertone
  class Mechanism
    # Parses a CIDR parameter subject to a max_val (32 for IPv4, 128 for IPv6)
    class CidrParser
      def self.parse(raw_length, max_val)
        return if raw_length.blank?
        length_as_i = raw_length.to_i
        if length_as_i < 0 || length_as_i > max_val
          fail Coppertone::InvalidMechanismError
        end
        length_as_i
      end
    end
  end
end
