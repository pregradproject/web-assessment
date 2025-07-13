module CkvExceptions
  class NotFoundError < StandardError
    attr_reader :code, :message

    def initialize(message = I18n.t('error.validation.not_found'))
      @code = 'CKV-404'
      @message = message

      super(@message)
    end
  end
end
