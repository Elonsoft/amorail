# Amorail Exceptions.
# Every class is name of HTTP response error code(status)
module Amorail
  # Internal exceptions
  Error = Class.new(StandardError)
  RecordNotFound = Class.new(Error)
  InvalidRecord = Class.new(Error)
  NotPersisted = Class.new(Error)

  # API Exceptions
  APIError = Class.new(Error)
  AmoBadRequestError = Class.new(APIError)
  AmoMovedPermanentlyError = Class.new(APIError)
  AmoUnauthorizedError = Class.new(APIError)
  AmoForbiddenError = Class.new(APIError)
  AmoNotFoundError = Class.new(APIError)
  AmoInternalError = Class.new(APIError)
  AmoBadGatewayError = Class.new(APIError)
  AmoServiceUnavailableError = Class.new(APIError)
  AmoUnknownError = Class.new(APIError)
end

