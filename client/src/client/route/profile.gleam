import client/data/user.{type User}
import client/network
import client/session.{type Session}
import lustre/effect.{type Effect}
import lustre/element.{type Element}

pub type Model {
  Model
}

pub type Msg {
  ApiReturnedUser(Result(User, network.Error))
}

pub fn init() -> #(Model, Effect(Msg)) {
  #(Model, effect.none())
}

pub fn update(
  session: Session,
  model: Model,
  msg: Msg,
) -> #(Session, Model, Effect(Msg)) {
  #(session, model, effect.none())
}

pub fn view(session: Session, model: Model) -> Element(Msg) {
  case session {
    session.Unknown -> element.text("trying to authenticate, please wait")
    session.LoggedOut -> element.text("please login to view this page")
    session.LoggedIn(user:) -> element.text("username: " <> user.username)
  }
}
