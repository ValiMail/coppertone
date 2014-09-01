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

    def self.register(type, klass)
      class_builder.register(type, klass)
    end

    MODIFIER_REGEXP = /\A([a-zA-Z]+[a-zA-Z0-9\-\_\.]*)=(\S*)\z/
    def self.matching_term(text)
      matches = MODIFIER_REGEXP.match(text)
      return nil unless matches
      type = matches[1]
      attributes = matches[2]
      build(type, attributes) || build('unknown', attributes)
    end
  end
end

require 'coppertone/modifier/exp'
require 'coppertone/modifier/redirect'
require 'coppertone/modifier/unknown'
