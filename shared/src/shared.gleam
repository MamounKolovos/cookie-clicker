pub type ApiErrorCode {
  InvalidFormCode
  InternalError
  Unauthorized
}

pub type ApiError {
  ApiError(code: ApiErrorCode, message: String)
}
