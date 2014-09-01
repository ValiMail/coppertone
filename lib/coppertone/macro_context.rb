require 'active_support/core_ext/module/delegation'
require 'addressable/uri'
require 'ostruct'
require 'uri'

module Coppertone
  # A context used to evaluate MacroStrings.  Responds to all of the
  # macro letter directives.
  class MacroContext
    attr_reader :domain, :ip_address_wrapper, :sender_identity, :helo_domain

    delegate :s, :l, :o, to: :sender_identity
    alias_method :d, :domain
    delegate :i, :p, :v, :c, to: :ip_address_wrapper
    delegate :ip_v4, :ip_v6, :original_ipv4?, :original_ipv6?,
             to: :ip_address_wrapper
    alias_method :h, :helo_domain

    attr_reader :hostname
    def initialize(domain, ip_as_s, sender, helo_domain = 'unknown',
                   options = {})
      @ip_address_wrapper = IPAddressWrapper.new(ip_as_s)
      @sender_identity = SenderIdentity.new(sender)
      @domain = domain || @sender_identity.domain
      @helo_domain = helo_domain
      @hostname = options[:hostname]
    end

    UNKNOWN_HOSTNAME = 'unknown'
    def r
      if Coppertone::Utils::DomainUtils.valid?(raw_hostname)
        raw_hostname
      else
        UNKNOWN_HOSTNAME
      end
    end

    def t
      Time.now.to_i
    end

    %w(s l o d i p v h c r t).each do |m|
      define_method(m.upcase) do
        unencoded = send(m)
        if unencoded
          ::URI.escape(unencoded, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        else
          nil
        end
      end
    end

    def raw_hostname
      @raw_hostname ||=
        (hostname || Coppertone.config.hostname ||
         Coppertone::Utils::HostUtils.hostname)
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
