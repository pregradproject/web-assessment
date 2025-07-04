module CkvExceptions
  class GoogleAuthRequiredError < StandardError
    attr_reader :code, :message

    def initialize(message = I18n.t('error.validation.google_auth_required'))
      @code = 'CKV-403'
      @message = message

      super(@message)
    end
  end
end
