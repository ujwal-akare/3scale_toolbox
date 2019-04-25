module ThreeScaleToolbox
  # Generic error. Superclass for all specific errors.
  class Error < ::StandardError
  end

  class InvalidUrlError < Error
  end

  class ActiveDocsNotFoundError < Error
    attr_reader :id

    def initialize(id)
      super("ActiveDocs with ID #{id} not found")
    end
  end

  class ThreeScaleApiError < Error
    attr_reader :apierrors

    def initialize(msg = '', apierrors = {})
      @apierrors = apierrors
      super(msg)
    end

    def message
      "#{super}. Errors: #{apierrors}"
    end
  end
end
