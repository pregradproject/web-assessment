module Exceptions
  class NotAllowedToDoThisAction < StandardError
    def message
      I18n.t 'error.validation.not_allowed_to_do_this_action'
    end
  end

  class MissingParameter < StandardError
    def initialize(param)
      @param = param
      super
    end

    def message
      I18n.t 'error.validation.parameter_required', param: @param
    end
  end

  class UnprocessableRequest < StandardError
    attr_reader :message

    def initialize(message)
      super
      @message = message
    end
  end

  class UnauthorizedAccess < StandardError; end
end
