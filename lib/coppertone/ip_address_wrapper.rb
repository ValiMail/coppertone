require 'ipaddr'

module Coppertone
  # A wrapper class for the IP address of the SMTP client that is emitting
  # the email and is being validated by the SPF process.  This class
  # contains a number of helper methods designed to support the use
  # of IPs in mechanism evaluation and macro string evaluation.
  #
  # Note: This class should only be used with a single IP address, and
  # will fail if passed an address with a prefix
  class IPAddressWrapper
    attr_reader :string_representation, :ip
    def initialize(s)
      @ip = self.class.parse(s)
      fail ArgumentError unless @ip
      @string_representation = s
    end

    def self.parse(s)
      return nil unless s
      return nil if s.index('/')
      ip_addr = IPAddr.new(s)
      normalize_ip(ip_addr)
    rescue IPAddr::InvalidAddressError
      nil
    end

    def self.normalize_ip(parsed_ip)
      return parsed_ip unless parsed_ip && parsed_ip.ipv6?
      parsed_ip.ipv4_mapped? ? parsed_ip.native : parsed_ip
    end

    def to_dotted_notation
      if original_ipv6?
        format('%.32x', @ip.to_i).split(//).join('.').upcase
      elsif original_ipv4?
        @ip.to_s
      end
    end
    alias_method :i, :to_dotted_notation

    def to_human_readable
      @ip.to_s
    end
    alias_method :c, :to_human_readable

    def v
      original_ipv4? ? 'in-addr' : 'ip6'
    end

    def p
      fail NotImplementedError
    end

    def ip_v4
      original_ipv4? ? @ip : nil
    end

    def ip_v6
      original_ipv6? ? @ip : nil
    end

    def original_ipv4?
      @ip.ipv4?
    end

    def original_ipv6?
      @ip.ipv6?
    end

    def to_s
      @string_representation
    end
  end
end
