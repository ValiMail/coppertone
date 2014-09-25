module Coppertone
  class Mechanism  # rubocop:disable Style/Documentation
    # Implements the ip4 mechanism.
    class IPMechanism < Mechanism
      attr_reader :ip_network
      def self.create(attributes)
        new(attributes)
      end

      def initialize(attributes)
        super(attributes)
        unless attributes.blank?
          attributes = attributes[1..-1] if attributes[0] == ':'
          @ip_network = parse_ip_network(attributes)
        end
        fail Coppertone::InvalidMechanismError if @ip_network.nil?
      end

      LEADING_ZEROES_IN_CIDR_REGEXP = /\/0\d/
      def validate_no_leading_zeroes_in_cidr(ip_as_s)
        return unless LEADING_ZEROES_IN_CIDR_REGEXP.match(ip_as_s)
        fail Coppertone::InvalidMechanismError
      end

      # Hack for JRuby - remove when JRuby moves to 2.0.x
      if RUBY_VERSION < '2.0'
        IP_PARSE_ERROR = ArgumentError
      else
        IP_PARSE_ERROR = IPAddr::Error
      end

      def parse_ip_network(ip_as_s)
        validate_no_leading_zeroes_in_cidr(ip_as_s)
        addr, cidr_length, dual = ip_as_s.split('/')
        return nil if dual
        network = IPAddr.new(addr)
        network = network.mask(cidr_length.to_i) unless cidr_length.blank?
        network
      rescue IP_PARSE_ERROR
        nil
      end

      def match?(macro_context, _request_context)
        ip = ip_for_match(macro_context)
        return false unless ip
        return false unless ip.ipv4? == @ip_network.ipv4?
        @ip_network.include?(ip)
      end

      def ==(other)
        return false unless other.instance_of? self.class
        ip_network == other.ip_network
      end
    end
  end
end
