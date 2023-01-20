import React from "react"
import logo from "./assets/100_on_chain-stripe-white_text.svg"
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
import TWITTER_ICON from "./assets/twitter.svg"
import BGIMG from "./assets/DALL·E 2022-08-03 08.33.15 - an man in a space suit floating in space welding an oil drum, digital art.png"

function App() {
  type Proposal = {
    id: bigint
    status: string
    vote: bigint
    pageText: string
  }
  type Result = { ok: Proposal } | { err: string }

  type Result_1 = { ok: null } | { err: string }

  type Result_2 = { ok: Array<Proposal> } | { err: string }

  type Result_3 = { ok: Array<string> } | { err: string }

  interface _SERVICE {
    getPageText: () => Promise<string>
    get_all_proposals: () => Promise<Result_2>
    submit_proposal: (arg_0: string) => Promise<Result_1>
    vote: (arg_0: bigint, string) => Promise<Result>
  }

  return (
    <div className="App">
      <div className="auth-section">
        <ConnectButton />
      </div>
      <ConnectDialog />

      <header className="App-header">
        <a>1. get MB tokens</a>
        <a>2. Create Proposal</a>
        <a>3. Vote </a>
        <a>4. View Certified DAO Text</a>
      </header>

      <div className="App-body">
        <p className="twitter">
          <Dao />{" "}
        </p>
        <img className="BGIMG" src={BGIMG} alt="bg" />
        <img src={logo} className="App-logo" alt="logo" />
        <div className="footer">
          <img src={TWITTER_ICON} className="twitter-icon" alt="twitter" />
          <a href="https://twitter.com/enterTheChain">@enterTheChain</a>
        </div>
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
