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
  @get external user: t<'user> => option<'user> = "user"
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

module type TokenModule = {
  @deriving(abstract)
  type getAccessTokenOptions = {
    @optional audience: string,
    @optional scope: string,
    @as("redirect_uri") redirectUri: string,
  }

  let getAccessToken: (t<'user>, ~options: getAccessTokenOptions=?, unit) => promise<string>

  let getAccessTokenWithPopup: (
    t<'user>,
    ~options: getAccessTokenOptions=?,
    unit,
  ) => promise<string>
}

module Token: TokenModule = {
  @deriving(abstract)
  type getAccessTokenOptions = {
    @optional audience: string,
    @optional scope: string,
    // optional but required, check: https://community.auth0.com/t/auth0-app-id-doesnt-link-with-the-android-application/67288/8
    @as("redirect_uri") redirectUri: string,
  }

  type authorizationParamsOptions = {authorizationParams: getAccessTokenOptions}

  @send
  external _getAccessToken: (
    t<'user>,
    ~options: authorizationParamsOptions=?,
    unit,
  ) => promise<string> = "getAccessTokenSilently"

  @send
  external _getAccessTokenPopup: (
    t<'user>,
    ~options: authorizationParamsOptions=?,
    unit,
  ) => promise<string> = "getAccessTokenWithPopup"

  let getAccessToken = (auth0, ~options: option<getAccessTokenOptions>=?, ()): promise<string> => {
    switch options {
    | Some(opts) => _getAccessToken(auth0, ~options={authorizationParams: opts}, ())
    | None => _getAccessToken(auth0, ())
    }
  }

  let getAccessTokenWithPopup = (auth0, ~options: option<getAccessTokenOptions>=?, ()): promise<
    string,
  > => {
    switch options {
    | Some(opts) => _getAccessTokenPopup(auth0, ~options={authorizationParams: opts}, ())
    | None => _getAccessToken(auth0, ())
    }
  }
}

@module("@auth0/auth0-react") external useAuth0: unit => t<'user> = "useAuth0"
@send external logout: (t<'user>, Logout.args) => promise<unit> = "logout"
