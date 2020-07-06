require 'active_support/core_ext/module/delegation'
require 'addressable/uri'
require 'ostruct'
require 'uri'

module Coppertone
  # A context used to evaluate MacroStrings.  Responds to all of the
  # macro letter directives except 'p'.
  class MacroContext
    attr_reader :domain, :ip_address_wrapper, :sender_identity, :helo_domain

    delegate :s, :l, :o, to: :sender_identity
    alias d domain
    delegate :i, :v, :c, to: :ip_address_wrapper
    delegate :ip_v4, :ip_v6, :original_ipv4?, :original_ipv6?,
             to: :ip_address_wrapper
    alias h helo_domain

    attr_reader :hostname

    def initialize(domain, ip_as_s, sender, helo_domain = 'unknown',
                   options = {})
      @ip_address_wrapper = IPAddressWrapper.new(ip_as_s)
      @sender_identity = SenderIdentity.new(sender)
      @domain = domain || @sender_identity.domain
      @helo_domain = helo_domain
      @hostname = options[:hostname]
    end

    UNKNOWN_HOSTNAME = 'unknown'.freeze
    def r
      valid = Coppertone::Utils::DomainUtils.valid?(raw_hostname)
      valid ? raw_hostname : UNKNOWN_HOSTNAME
    end

    def t
      Time.now.to_i
    end

    RESERVED_REGEXP = Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
    %w[s l o d i v h c r t].each do |m|
      define_method(m.upcase) do
        unencoded = send(m)
        unencoded ? ::URI.escape(unencoded, RESERVED_REGEXP) : nil
      end
    end

    def raw_hostname
      @raw_hostname ||=
        begin
          hostname || Coppertone.config.hostname || Coppertone::Utils::HostUtils.hostname
        end
    end

    # Generates a new MacroContext with all the same info, but a new
    # domain
    def with_domain(new_domain)
      options = {}
      options[:hostname] = hostname if hostname
      MacroContext.new(new_domain, c, s, h, options)
    end
  end
end
