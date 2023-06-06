type t<'user>

module type LogoutOptions = {
  type args
  let options: (~returnTo: string) => args
}

module Logout: LogoutOptions = {
  type params = {returnTo: string}
  type args = {logoutParams: params}
  let options: (~returnTo: string) => args = (~returnTo: string) => {
    logoutParams: {returnTo: returnTo},
  }
}

module Login = {
  type authParams
  @obj external authParams: (~redirect_uri: string, ~scope: string=?, unit) => authParams = ""

  type redirectOptions
  @obj
  external redirectOptions: (~redirectTo: string => promise<unit>=?, unit) => redirectOptions = ""

  type popupLoginOptions
  @obj external popupLoginOptions: (~authorizationParams: authParams=?) => popupLoginOptions = ""

  type popupConfigOptions
  @obj external popupConfigOptions: (~timeoutInSeconds: int=?) => popupConfigOptions = ""

  @send
  external withRedirect: (t<'user>, ~redirectOptions: redirectOptions=?, unit) => unit =
    "loginWithRedirect"
  @send
  external withPopup: (
    t<'user>,
    ~loginOptions: popupLoginOptions=?,
    ~configOptions: popupConfigOptions=?,
    unit,
  ) => unit = "loginWithPopup"
}

module State = {
  @get external isLoading: t<'user> => bool = "isLoading"
  @get external isAuthenticated: t<'user> => bool = "isAuthenticated"
  @get external error: t<'user> => option<Js.Exn.t> = "error"
  @get external user: t<'user> => 'user = "user"
}

module ContextProvider = {
  @module("@auth0/auth0-react") @react.component
  external make: (
    ~domain: string,
    ~clientId: string,
    ~children: React.element,
    ~authorizationParams: Login.authParams=?,
  ) => React.element = "Auth0Provider"
}

@module("@auth0/auth0-react") external useAuth0: unit => t<'user> = "useAuth0"
@send external logout: (t<'user>, Logout.args) => promise<unit> = "logout"
