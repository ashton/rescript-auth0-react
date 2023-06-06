# Rescript Auth0 React
Bindings for [@auth0/auth0-react](https://github.com/auth0/auth0-react/tree/master#documentation), Auth0's library for react applications.

## Instalation
Install the dependency on your project:

```shell
npm install @auth0/auth0-react rescript-auth0-react
```

Add the dependency to your `bsconfig.json`:

```json
{"bs-dependencies": ["rescript-auth0-react"]}
```

## Usage

### Configure the provider
According with [Auth0 React Guide](https://auth0.com/docs/quickstart/spa/react) you need to configure an application in Auth0 and use this application's `domain` and `clientId` in order to configure your Auth0 React Provider.


```rescript
//App.res
@val @scope(("window", "location")) external origin = "origin"

let Auth0Provider = Auth0React.ContextProvider

// The follow URL must be registered at your Auth0 application's callback urls
let authParams = Auth0React.Login.authParams(~redirect_uri=origin)

<Auth0Provider domain="AUTH0_APPLICATION_DOMAIN_HERE" clientId="AUTH0_APPLICATION_CLIENT_ID_HERE" authorizationParams=authParams>
{/*Your application content here*/}
</Auth0Provider>
```

### Auth0 Hook
Inside any component that is under the Auth0 provider configured above you can use the `Auth0React.useAuth0` hook to obtain all you need to manage your Auth0 integration.

#### Login
```rescript
// login.res

let make = () => {
  let auth0 = auth0react.useauth0()

  <button onclick={(_) => auth0->auth0react.login.withredirect()}>
    {rescript.string("login")}
  </button>
}
```

#### Logout
```rescript
// logout.res
@val @scope(("window", "location")) external origin = "origin"

let make = () => {
  let auth0 = auth0react.useauth0()
  let logoutOptions = Auth0React.Logout.options(~returnTo=origin)

  <button onclick={(_) => auth0->auth0react.logout(logoutOptions)}>
    {rescript.string("logout")}
  </button>
}
```

#### Authentication data
```rescript
// profile.res
let make = () => {
  // you can specify your own user type
  let auth0: Auth0React.t<User.t> = auth0react.useauth0()

  if(auth0->Auth0React.State.isAuthenticated) {
    let user: User.t = auth0->Auth0React.State.user

    <div>{React.string(user.name)}</div>
  }
}

```
the `State` module is composed by the following data:

* `isLoading`
* `isAuthenticated`
* `error`
* `user`
