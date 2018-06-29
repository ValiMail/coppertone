module Coppertone
  class Mechanism
    # Implements the ip4 mechanism.
    class IPMechanism < Mechanism
      attr_reader :netblock, :cidr_length
      def self.create(attributes)
        new(attributes)
      end

      def initialize(attributes)
        super(attributes)
        unless attributes.blank?
          attributes = attributes[1..-1] if attributes[0] == ':'
          @netblock, @cidr_length = parse_netblock(attributes)
        end
        raise Coppertone::InvalidMechanismError if @netblock.nil?
      end

      LEADING_ZEROES_IN_CIDR_REGEXP = %r{\/0\d}
      def validate_no_leading_zeroes_in_cidr(ip_as_s)
        return unless LEADING_ZEROES_IN_CIDR_REGEXP.match?(ip_as_s)
        raise Coppertone::InvalidMechanismError
      end

      # Hack for JRuby - remove when JRuby moves to 2.0.x
      IP_PARSE_ERROR = if RUBY_VERSION < '2.0'
                         ArgumentError
                       else
                         IPAddr::Error
                       end

      def parse_netblock(ip_as_s)
        validate_no_leading_zeroes_in_cidr(ip_as_s)
        addr, cidr_length_as_s, dual = ip_as_s.split('/')
        return [nil, nil] if dual
        network = IPAddr.new(addr)
        network = network.mask(cidr_length_as_s.to_i) unless cidr_length_as_s.blank?
        cidr_length = cidr_length_as_s.blank? ? default_cidr(network) : cidr_length_as_s.to_i
        [network, cidr_length]
      rescue IP_PARSE_ERROR
        [nil, nil]
      end

      def default_cidr(network)
        network.ipv6? ? 128 : 32
      end

      def match?(macro_context, _request_context)
        ip = ip_for_match(macro_context)
        return false unless ip
        return false unless ip.ipv4? == @netblock.ipv4?
        @netblock.include?(ip)
      end

      def ==(other)
        return false unless other.instance_of? self.class
        netblock == other.netblock
      end
    end
  end
end
