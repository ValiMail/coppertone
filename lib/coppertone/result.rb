module Coppertone
  # The result of an SPF query.  Includes a code, which indicates the
  # overall result (pass, fail, softfail, etc.).  For different
  # results it may include the mechanism which led to the result,
  # an error message, and/or an explanation string.
  class Result
    NONE = :none

    PASS = :pass
    FAIL = :fail
    SOFTFAIL = :softfail
    NEUTRAL = :neutral

    TEMPERROR = :temperror
    PERMERROR = :permerror

    attr_reader :code, :mechanism
    attr_accessor :explanation, :problem, :identity
    def initialize(code, mechanism = nil)
      @code = code
      @mechanism = mechanism
    end

    def self.from_directive(directive)
      new(directive.qualifier.result_code, directive.mechanism)
    end

    def self.permerror(message)
      r = Result.new(:permerror)
      r.problem = message
      r
    end

    def self.temperror(message)
      r = Result.new(:temperror)
      r.problem = message
      r
    end

    def self.none
      Result.new(:none)
    end

    def self.neutral
      Result.new(:neutral)
    end

    %w(none pass fail softfail neutral temperror permerror).each do |t|
      define_method("#{t}?") do
        self.class.const_get(t.upcase) == send(:code)
      end
    end
  end
end
