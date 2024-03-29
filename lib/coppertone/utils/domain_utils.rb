require 'addressable/idna'

module Coppertone
  module Utils
    # A utility class that includes methods for working with
    # domain names.
    class DomainUtils
      def self.valid?(domain)
        return false if domain.blank?
        return false if domain.length > 253

        labels_valid?(to_ascii_labels(domain))
      end

      def self.labels_valid?(labels)
        return false if labels.length <= 1
        return false if labels.first == '*'
        return false unless valid_tld?(labels.last)

        labels.all? { |l| valid_label?(l) }
      end

      def self.to_labels(domain)
        domain.split('.')
      end

      def self.parent_domain(domain)
        labels = to_labels(domain)
        return '.' if labels.size == 1

        labels.shift
        labels.join('.')
      end

      def self.to_ascii_labels(domain)
        Addressable::IDNA.to_ascii(domain).split('.').map(&:downcase)
      end

      def self.normalized_domain(domain)
        to_ascii_labels(domain).join('.')
      end

      NO_DASH_NONNUMERIC_REGEXP = /\A[a-zA-Z0-9]*[a-zA-Z]+[a-zA-Z0-9]*\z/.freeze
      NO_DASH_REGEXP = /\A[a-zA-Z0-9]+\z/.freeze
      DASH_REGEXP = /\A[a-zA-Z0-9]+-[a-zA-Z0-9\-]*[a-zA-Z0-9]+\z/.freeze

      def self.valid_hostname_label?(l)
        return false unless valid_label?(l)

        NO_DASH_REGEXP.match(l) || DASH_REGEXP.match(l)
      end

      def self.valid_tld?(l)
        return false unless valid_label?(l)

        NO_DASH_NONNUMERIC_REGEXP.match(l) || DASH_REGEXP.match(l)
      end

      def self.valid_ldh_domain?(domain)
        return false unless valid?(domain)

        labels = to_ascii_labels(domain)
        return false unless valid_tld?(labels.last)

        labels.all? { |l| valid_hostname_label?(l) }
      end

      def self.valid_label?(l)
        !l.empty? && (l.length <= 63) && !l.match(/(\s|@|;)/)
      end

      def self.macro_expanded_domain(domain)
        return nil if domain.blank?

        labels = to_ascii_labels(domain)
        domain = labels.join('.')
        while domain.length > 253
          labels = labels.drop(1)
          domain = labels.join('.')
        end
        domain
      end

      def self.subdomain_of?(subdomain_candidate, domain)
        subdomain_labels = to_ascii_labels(subdomain_candidate)
        domain_labels = to_ascii_labels(domain)
        num_labels_in_domain = domain_labels.length
        return false if subdomain_labels.length <= domain_labels.length

        subdomain_labels.last(num_labels_in_domain) == domain_labels
      end

      def self.subdomain_or_same?(candidate, domain)
        return false unless valid?(domain) && valid?(candidate)
        return true if normalized_domain(domain) == normalized_domain(candidate)

        subdomain_of?(candidate, domain)
      end
    end
  end
end
