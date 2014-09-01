module Coppertone
  class Error < ::StandardError
  end

  class TemperrorError < Coppertone::Error; end
  class PermerrorError < Coppertone::Error; end

  class InvalidSenderError < Coppertone::Error; end
  class MissingNameError < Coppertone::PermerrorError; end
  class MissingQualifierError < Coppertone::PermerrorError; end

  class MacroStringParsingError < Coppertone::PermerrorError; end
  class DomainSpecParsingError < MacroStringParsingError; end

  class RecordParsingError < Coppertone::PermerrorError; end
  class InvalidMechanismError < Coppertone::RecordParsingError; end
  class InvalidModifierError < Coppertone::RecordParsingError; end

  class MissingSpfRecordError < Coppertone::Error; end
  class AmbiguousSpfRecordError < Coppertone::PermerrorError; end

  class NoneIncludeResultError < Coppertone::PermerrorError; end
  class InvalidRedirectError < Coppertone::PermerrorError; end

  class LimitExceededError < Coppertone::PermerrorError; end
  class TermLimitExceededError < PermerrorError; end
  class VoidLimitExceededError < PermerrorError; end
  class MXLimitExceededError < PermerrorError; end
end
