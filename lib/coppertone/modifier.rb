module Coppertone
  # Instances of this class represent modifier terms, as defined by the
  # SPF specification (see section 4.6.1).
  class Modifier
    def self.class_builder
      @class_builder ||= ClassBuilder.new
    end

    def self.build(type, attributes)
      class_builder.build(type, attributes)
    end

    def self.register(klass)
      class_builder.register(klass.label, klass)
    end

    MODIFIER_REGEXP = /\A([a-zA-Z]+[a-zA-Z0-9\-\_\.]*)=(\S*)\z/.freeze
    def self.matching_term(text)
      matches = MODIFIER_REGEXP.match(text)
      return nil unless matches

      type = matches[1]
      attributes = matches[2]
      build(type, attributes) || build_unknown(type, attributes)
    end

    def self.build_unknown(type, attributes)
      Coppertone::Modifier::Unknown.new(type, attributes)
    end

    attr_reader :arguments
    def initialize(arguments)
      @arguments = arguments
    end

    def label
      self.class.label
    end

    def to_s
      "#{label}=#{arguments}"
    end
  end
end

require 'coppertone/modifier/exp'
require 'coppertone/modifier/redirect'
require 'coppertone/modifier/unknown'
