module Vark
  class CertificateDownloadValidator
    def initialize(order)
      @validator = Orders::CertificateDownloadValidator.new(order)
    end

    def valid?
      @validator.valid?
    end

    def errors
      @validator.errors
    end
  end
end
