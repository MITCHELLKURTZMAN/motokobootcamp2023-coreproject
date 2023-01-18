import React from "react"
import logo from "./assets/dfinity.svg"
/*
 * Connect2ic provides essential utilities for IC app development
 */
import { createClient } from "@connect2ic/core"
import { defaultProviders } from "@connect2ic/core/providers"
import {
  ConnectButton,
  ConnectDialog,
  Connect2ICProvider,
} from "@connect2ic/react"
import "@connect2ic/core/style.css"
/*
 * Import canister definitions like this:
 */
import * as counter from "../.dfx/local/canisters/counter"
import * as dao from "../.dfx/local/canisters/dao"
import { _SERVICE } from "src/declarations/dao/dao.did"
//import { canisterId as daoCanisterId } from "src/declarations/dao"
//import { getPageText } from "src/declarations/dao/dao.did"

/*
 * Some examples to get you started
 */

import { Transfer } from "./components/Transfer"
import { Profile } from "./components/Profile"
import { Dao } from "./components/dao"

function App() {
  interface _SERVICE {
    getPageText: () => Promise<string>
  }
  const [daoText, setDaoText] = React.useState("")

  return (
    <div className="App">
      <div className="auth-section">
        <ConnectButton />
      </div>
      <ConnectDialog />

      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <Dao />
        <p className="twitter">
          {" "}
          <a href="https://twitter.com/enterTheChain">@enterTheChain</a>
        </p>
      </header>

      <p className="examples-title">Examples</p>
      <div className="examples">
        <Profile />
        <Transfer />
      </div>
    </div>
  )
}

const client = createClient({
  canisters: {
    dao,
    counter,
  },
  providers: defaultProviders,
  globalProviderConfig: {
    dev: import.meta.env.DEV,
  },
})

export default () => (
  <Connect2ICProvider client={client}>
    <App />
  </Connect2ICProvider>
)
