module Coppertone
  class Error < ::StandardError
  end

  # Error classes mapping to the SPF result codes
  class TemperrorError < Coppertone::Error; end

  class PermerrorError < Coppertone::Error; end

  # Errors occurring when the string representation of a MacroString
  # or DomainSpec does not obey the syntax requirements.
  class MacroStringParsingError < Coppertone::PermerrorError; end

  class DomainSpecParsingError < MacroStringParsingError; end

  # Occurs when an SPF record cannot be parsed.
  class RecordParsingError < Coppertone::PermerrorError; end

  # Occurs when an individual mechanism cannot be parsed, usually
  # because the arguments passed to the mechanism are not syntactically
  # valid.
  class InvalidMechanismError < Coppertone::RecordParsingError; end

  # Occurs when an individual modifier cannot be parsed, usually
  # because the arguments passed to the modifier are not syntactically
  # valid.
  class InvalidModifierError < Coppertone::RecordParsingError; end

  # Occurs when an SPF record cannot be parsed because of a duplicate
  # modifier.
  class DuplicateModifierError < Coppertone::RecordParsingError; end

  # Occurs when more than one potential SPF record is found for a
  # domain.
  class AmbiguousSpfRecordError < Coppertone::PermerrorError; end

  # Occurs when the SPF record referenced by an include mechanism
  # yields a 'none' result.  This results in a permerror.
  class NoneIncludeResultError < Coppertone::PermerrorError; end

  # Occurs when an SPF record cannot be found for the domain
  # referenced in a redirect macro.
  class InvalidRedirectError < Coppertone::PermerrorError; end

  # Errors generated when certain spec-defined limits are exceeded.
  class LimitExceededError < Coppertone::PermerrorError; end

  class TermLimitExceededError < PermerrorError; end

  class VoidLimitExceededError < PermerrorError; end

  class MXLimitExceededError < PermerrorError; end

  # Raised when context is required to evaluate a value, but
  # context is not available
  class NeedsContextError < Coppertone::Error; end
end
