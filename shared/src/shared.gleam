pub type ApiErrorCode {
  InvalidFormCode
  InternalError
}

pub type ApiError {
  ApiError(code: ApiErrorCode, message: String)
}
