module CkvExceptions
  class ForbiddenError < StandardError
    attr_reader :code, :message

    def initialize(message = I18n.t('error.validation.forbidden'))
      @code = 'CKV-403'
      @message = message

      super(@message)
    end
  end
end
