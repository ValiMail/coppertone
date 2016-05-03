module Coppertone
  # A utility class that encapsulates counter and limit behavior.  Primarily
  # used to track and limit the number of DNS queries of various types.
  class RequestCountLimiter
    attr_accessor :count, :limit, :counter_description
    def initialize(limit = nil, counter_description = nil)
      self.limit = limit
      self.counter_description = counter_description
      self.count = 0
    end

    def increment!(num = 1)
      self.count += num
      check_if_limit_exceeded
      count
    end

    def check_if_limit_exceeded
      return if limit.nil?
      raise Coppertone::LimitExceededError, exception_message if exceeded?
    end

    def exception_message
      "Maximum #{counter_description} limit of #{limit} exceeded."
    end

    def exceeded?
      return false unless limited?
      count > limit
    end

    def limited?
      !limit.nil?
    end
  end
end
