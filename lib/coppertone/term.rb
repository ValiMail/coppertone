module Coppertone
  # Instances of this class represent terms as defined in section 4.6.1 of
  # the specification.  The Term class should be considered abstract,
  # and should only be instantiated as its concrete subclasses.  Terms
  # are generally parsed from text tokens in an SPF TXT record using the
  # factory method in this class.
  class Term
    def self.build_from_token(token)
      return nil unless token

      Directive.matching_term(token) || Modifier.matching_term(token)
    end
  end
end
