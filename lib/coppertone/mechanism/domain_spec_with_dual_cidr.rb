require 'coppertone/mechanism/domain_spec_mechanism'
require 'ipaddr'
require 'coppertone/mechanism/cidr_parser'

module Coppertone
  class Mechanism
    # Parent class for mechanisms that use a domain spec, and permit
    # specification of an optional IPv4 CIDR and optional IPv6 CIDR.
    class DomainSpecWithDualCidr < DomainSpecMechanism
      def self.create(attributes)
        new(attributes)
      end

      def initialize(attributes)
        super
        return if attributes.blank?

        parse_argument(attributes)
      rescue Coppertone::MacroStringParsingError
        raise Coppertone::InvalidMechanismError
      end

      def ip_v4_cidr_length
        @ip_v4_cidr_length ||= 32
      end

      def ip_v6_cidr_length
        @ip_v6_cidr_length ||= 128
      end

      def match?(macro_context, request_context)
        request_context.register_dns_lookup_term
        target_name = generate_target_name(macro_context, request_context)
        if target_name
          match_target_name(macro_context, request_context, target_name)
        else
          handle_invalid_domain(macro_context, request_context)
        end
      end

      CIDR_REGEXP = %r{(/(\d*))?(//(\d*))?\z}.freeze
      def parse_argument(attributes)
        raise InvalidMechanismError if attributes.blank?

        cidr_matches = CIDR_REGEXP.match(attributes)
        raise InvalidMechanismError unless cidr_matches

        macro_string, raw_ip_v4_cidr_length, raw_ip_v6_cidr_length =
          clean_matches(attributes, cidr_matches)
        process_matches(macro_string, raw_ip_v4_cidr_length,
                        raw_ip_v6_cidr_length)
      end

      def parse_domain_spec(attributes, domain_spec_end)
        return nil if attributes.blank?

        cand = attributes[0..domain_spec_end]
        return nil if cand.blank?

        cand = trim_domain_spec(cand)
        # At this point we've ascertained that there is
        # a body to the domain spec
        raise InvalidMechanismError if cand.blank?

        cand
      end

      def clean_matches(attributes, cidr_matches)
        raw_ip_v4_cidr_length = cidr_matches[2] unless cidr_matches[2].blank?
        raw_ip_v6_cidr_length = cidr_matches[4] unless cidr_matches[4].blank?
        term = cidr_matches[0]
        domain_spec_end = term.blank? ? -1 : (-1 - term.length)
        macro_string = parse_domain_spec(attributes, domain_spec_end)
        [macro_string, raw_ip_v4_cidr_length, raw_ip_v6_cidr_length]
      end

      def process_matches(macro_string, raw_ip_v4_cidr_length,
                          raw_ip_v6_cidr_length)
        @domain_spec = Coppertone::DomainSpec.new(macro_string) if macro_string
        parse_v4_cidr_length(raw_ip_v4_cidr_length)
        parse_v6_cidr_length(raw_ip_v6_cidr_length)
      end

      def parse_v4_cidr_length(raw_length)
        @ip_v4_cidr_length = CidrParser.parse(raw_length, 32)
      end

      def parse_v6_cidr_length(raw_length)
        @ip_v6_cidr_length = CidrParser.parse(raw_length, 128)
      end

      def generate_target_name(macro_context, request_context)
        if domain_spec
          target_name_from_domain_spec(macro_context, request_context)
        else
          macro_context.domain
        end
      end

      def handle_invalid_domain(_macro_context, _options)
        raise RecordParsingError
      end

      def ==(other)
        return false unless other.instance_of? self.class

        domain_spec == other.domain_spec &&
          ip_v4_cidr_length == other.ip_v4_cidr_length &&
          ip_v6_cidr_length == other.ip_v6_cidr_length
      end
      alias eql? ==

      def hash
        domain_spec.hash ^ ip_v4_cidr_length.hash ^ ip_v6_cidr_length.hash
      end
    end
  end
end
