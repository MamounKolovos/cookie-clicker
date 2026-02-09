pub type ApiErrorCode {
  InvalidFormCode
  InternalError
  Unauthorized
  InvalidCredentials
  DuplicateIdentifier
}

pub type ApiError {
  ApiError(code: ApiErrorCode, message: String)
}
