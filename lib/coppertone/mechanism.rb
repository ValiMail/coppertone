require 'coppertone/class_builder'

module Coppertone
  # The class itself is primarily used as a factory for creating
  # concrete mechanism instances based on a mechanism type
  # string and corresponding attribute string.  Validation of
  # the type is done here, while validation of the attributes
  # is delegated to the class corresponding to the
  # mechanism type
  class Mechanism
    def self.class_builder
      @class_builder ||= ClassBuilder.new
    end

    def self.build(type, attributes)
      class_builder.build(type, attributes)
    end

    def self.register(klass)
      raise ArgumentError unless klass < self

      class_builder.register(klass.label, klass)
    end

    def self.dns_lookup_term?
      false
    end

    attr_reader :arguments

    def initialize(arguments)
      @arguments = arguments
    end

    def dns_lookup_term?
      self.class.dns_lookup_term?
    end

    def to_s
      mech_label = self.class.label
      arguments.blank? ? mech_label : "#{mech_label}#{arguments}"
    end

    def context_dependent?
      false
    end

    def includes_ptr?
      false
    end
  end
end

require 'coppertone/mechanism/a'
require 'coppertone/mechanism/all'
require 'coppertone/mechanism/exists'
require 'coppertone/mechanism/include'
require 'coppertone/mechanism/ip4'
require 'coppertone/mechanism/ip6'
require 'coppertone/mechanism/mx'
require 'coppertone/mechanism/ptr'
