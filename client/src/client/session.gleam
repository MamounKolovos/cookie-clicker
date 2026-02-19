import client/data/user.{type User}

pub type Session {
  /// initial state on page reload
  /// before update has had a chance to resolve to actual state
  Unknown
  LoggedOut
  LoggedIn(user: User)
}

pub fn unknown() -> Session {
  Unknown
}

pub fn logout() -> Session {
  LoggedOut
}

pub fn login(user: User) -> Session {
  LoggedIn(user:)
}
