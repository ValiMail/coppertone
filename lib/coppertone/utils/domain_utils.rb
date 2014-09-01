require 'addressable/idna'

module Coppertone
  module Utils
    # A utility class that includes methods for working with
    # domain names.
    class DomainUtils
      def self.valid?(domain)
        return false if domain.blank?
        labels = to_labels(domain)
        return false if labels.length <= 1
        return false if domain.length > 253
        return false if labels.any? { |l| !valid_label?(l) }
        true
      end

      def self.to_labels(domain)
        Addressable::IDNA.to_ascii(domain).split('.')
      end

      NO_DASH_REGEXP = /\A[a-zA-Z0-9]*[a-zA-Z]+[a-zA-Z0-9]*\z/
      DASH_REGEXP = /\A[a-zA-Z0-9]+\-[a-zA-Z0-9\-]*[a-zA-Z0-9]+\z/

      def self.valid_hostname_label?(l)
        return false unless valid_label?(l)
        NO_DASH_REGEXP.match(l) || DASH_REGEXP.match(l)
      end

      def self.valid_label?(l)
        (l.length >= 0) && (l.length <= 63)
      end

      def self.macro_expanded_domain(domain)
        return nil if domain.blank?
        labels = to_labels(domain)
        domain = labels.join('.')
        while domain.length > 253
          labels = labels.drop(1)
          domain = labels.join('.')
        end
        domain
      end

      def self.subdomain_of?(subdomain_candidate, domain)
        subdomain_labels = to_labels(subdomain_candidate)
        domain_labels = to_labels(domain)
        num_labels_in_domain = domain_labels.length
        return false if subdomain_labels.length <= domain_labels.length
        subdomain_labels.last(num_labels_in_domain) == domain_labels
      end

      def self.subdomain_or_same?(candidate, domain)
        return false unless valid?(domain) && valid?(candidate)
        return true if domain == candidate
        subdomain_of?(candidate, domain)
      end
    end
  end
end
