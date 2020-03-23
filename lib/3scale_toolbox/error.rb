module ThreeScaleToolbox
  # Generic error. Superclass for all specific errors.
  class Error < ::StandardError
    def code
      'E_3SCALE'
    end

    def kind
      self.class
    end

    def stacktrace
      # For managed errors, stacktrace should not be necessary
      nil
    end
  end

  class InvalidUrlError < Error
    def code
      'E_INVALID_URL'
    end
  end

  class ActiveDocsNotFoundError < Error
    attr_reader :id

    def initialize(id)
      super("ActiveDocs with ID #{id} not found")
    end

    def code
      'E_ACTIVEDOCS_NOT_FOUND'
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

    def code
      'E_3SCALE_API'
    end
  end

  class InvalidIdError < Error
    def code
      'E_INVALID_ID'
    end
  end

  class UnexpectedError < ::StandardError
    attr_reader :unexpectederror

    def initialize(err)
      @unexpectederror = err
    end

    def message
      unexpectederror.message
    end

    def kind
      unexpectederror.class
    end

    def code
      'E_UNKNOWN'
    end

    def stacktrace
      unexpectederror.backtrace
    end
  end
end
