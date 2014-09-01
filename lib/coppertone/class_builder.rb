module Coppertone
  # Utility class for building class instances out of a set of
  # registered types (e.g. mechanisms, modifiers)
  class ClassBuilder
    def map
      @map ||= {}
    end

    def register(type, klass)
      map[type] = klass
    end

    def build(type, attributes)
      return nil unless type
      klass = map[type]
      return nil unless klass
      klass.create(attributes)
    end
  end
end
