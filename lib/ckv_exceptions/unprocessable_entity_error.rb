module CkvExceptions
  class UnprocessableEntityError < StandardError
    attr_reader :code, :errors, :message

    def initialize(errors, message = I18n.t('error.validation.unprocessable_entity'))
      @code = 'CKV-422'
      @errors = errors
      @message = message

      super(@message)
    end
  end
end
