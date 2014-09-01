require 'coppertone/error'

module Coppertone
  module DNS
    class Error < ::Coppertone::TemperrorError; end
    class TimeoutError < Error; end
    class NXDomainError < Error; end
  end
end
