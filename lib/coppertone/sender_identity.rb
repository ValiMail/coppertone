module Coppertone
  # A consolidated sender identity, suitable for use with an SPF request.
  # Parses the identity and ensures validity.  Also has accessor methods
  # for the macro letters.
  class SenderIdentity
    DEFAULT_LOCALPART = 'postmaster'.freeze
    EMAIL_ADDRESS_SPLIT_REGEXP = /^(.*)@(.*?)$/.freeze

    attr_reader :sender, :localpart, :domain
    def initialize(sender)
      @sender = sender
      initialize_localpart_and_domain
    end

    alias s sender
    alias l localpart
    alias o domain

    private

    def initialize_localpart(matches)
      localpart_candidate = matches[1] if matches
      @localpart =
        localpart_candidate.blank? ? DEFAULT_LOCALPART : localpart_candidate
    end

    def initialize_domain(matches)
      domain_candidate = matches[2] if matches
      @domain =
        domain_candidate.blank? ? sender : domain_candidate
    end

    def initialize_localpart_and_domain
      matches = EMAIL_ADDRESS_SPLIT_REGEXP.match(sender)
      initialize_localpart(matches)
      initialize_domain(matches)
    end
  end
end
