module ThreeScaleToolbox
  # Generic error. Superclass for all specific errors.
  class Error < ::StandardError
  end

  class InvalidUrlError < Error
  end
end
