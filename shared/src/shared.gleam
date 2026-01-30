pub type ApiErrorCode {
  InvalidFormCode
  InternalError
}

pub type ApiError {
  ApiError(code: ApiErrorCode, message: String)
}

pub type Signup {
  Signup(email: String, username: String, password: String)
}
