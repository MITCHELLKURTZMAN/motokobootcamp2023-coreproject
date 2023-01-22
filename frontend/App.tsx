import React, { useEffect } from "react"
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

import * as dao from "../.dfx/local/canisters/dao"
import { _SERVICE } from "src/declarations/dao/dao.did"
//import { canisterId as daoCanisterId } from "src/declarations/dao"
//import { getPageText } from "src/declarations/dao/dao.did"

import { Dao } from "./components/dao"
import TWITTER_ICON from "./assets/twitter.svg"
import GITHUB_ICON from "./assets/github.svg"
import ICP from "./assets/Motoko_logo_text_-_white.png"
import { useCanister } from "@connect2ic/react"
//import BGIMG from "./assets/DALL·E 2022-08-03 08.33.15 - an man in a space suit floating in space welding an oil drum, digital art.png"

function App() {
  const [principalId, setPrincipalId] = React.useState<string>("")
  const [dao] = useCanister("dao")

  const getPrincipalId = async () => {
    try {
      const principalId = (await dao.getPrincipalId()) as string
      setPrincipalId(principalId)
    } catch (e) {
    } finally {
      alert(principalId)
    }
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1 className="cool-header">About the Demo</h1>
        <p
          style={{
            fontFamily: "none",
            padding: "0px 50px 0px 50px",
            fontSize: "medium",
          }}
        >
          Since this project was time restrained and motoko focused, some of the
          sacrifices were made in the UI/UX to meet backend requirements, so I
          will explain quickly here how to use:
          <ul>
            <li>
              The first thing you should do is connect your wallet w/ the
              connect button at the top
            </li>
            <li>
              Next use the{" "}
              {
                <button onClick={() => getPrincipalId()}>
                  {" "}
                  Click to see principal{" "}
                </button>
              }{" "}
              button grab your principalId and fund your account with{" "}
              <a href="https://dpzjy-fyaaa-aaaah-abz7a-cai.ic0.app/">
                MB tokens
              </a>
            </li>
            <li>
              At this point you can create/vote on proposals. For added voting
              power, you can create a neuron 👇
            </li>
            <li>
              Next you can create a neuron, you can set the stake and a dissolve
              delay to which the tokens are stored at a subaccount that is
              controlled by the dao.
            </li>
          </ul>
          <p>
            {" "}
            Here is the{" "}
            <a href=" https://ushh5-caaaa-aaaak-ad72a-cai.ic0.app/">
              blackholed canister
            </a>{" "}
            with the "certified" text.{" "}
          </p>
          <p>
            If there are any issues with the UI/UX here is the{" "}
            <a href="https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=dctdl-jaaaa-aaaag-abd5q-cai">
              {" "}
              Candid Interface
            </a>
          </p>
        </p>

        {/* <span>Your principalId is: {principalId}</span> */}
      </header>
      <div className="auth-section">
        <ConnectButton
          onConnect={() => {
            console.log("Connected")

            console.log("principalId", principalId)
          }}
        />
        {/* <span> MB TOKENS: </span> */}
      </div>
      <ConnectDialog />

      <div className="App-body">
        <Dao principalId={principalId} /> <p className="twitter"></p>
        {/* <img
          className="BGIMG"
          style={{ marginTop: "10px" }}
          src={BGIMG}
          alt="bg"
        /> */}
        <img src={logo} className="App-logo" alt="logo" />
        <div className="footer">
          <div>
            <div>
              <div className="social-container">
                <img
                  src={TWITTER_ICON}
                  className="twitter-icon"
                  alt="twitter"
                />
                <a href="https://twitter.com/enterTheChain">@enterTheChain</a>
              </div>
              <div className="social-container">
                <img
                  src={GITHUB_ICON}
                  className="twitter-icon"
                  alt="Github icon"
                />
                <a href="https://github.com/MITCHELLKURTZMAN/motokobootcamp2023-coreproject">
                  MITCHELLKURTZMAN/motokobootcamp
                </a>
              </div>
              <div className="social-container">
                <span>💀 </span>
                <a href="https://ushh5-caaaa-aaaak-ad72a-cai.ic0.app/">
                  View Certified DAO Text
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

const client = createClient({
  canisters: {
    dao,
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
