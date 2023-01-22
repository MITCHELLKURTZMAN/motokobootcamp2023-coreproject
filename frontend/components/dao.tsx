import {
  Result_1,
  Proposal,
  Result_4,
  Result_2,
  Neuron,
  NeuronState,
  PublicChat,
} from ".dfx/local/canisters/dao/dao.did"
import { useCanister } from "@connect2ic/react"
import React, { useEffect, useState } from "react"

//props
interface DaoProps {
  principalId: string
}

const Dao = (DaoProps) => {
  const [dao] = useCanister("dao")
  const [pageText, setPageText] = useState<string>()
  const [allProposals, setAllProposals] = useState<Result_4 | String>()
  const [proposalID, setProposalID] = useState<string>()
  const [proposalStatus, setProposalStatus] = useState<string>()
  const [proposedText, setProposedText] = useState<string>()
  const [votePercent, setVotePercent] = useState<string>()
  const [voteYesOrNo, setVoteYesOrNo] = useState<string>()
  const [voteId, setVoteId] = useState<string>()
  const [principalId, setPrincipalId] = useState<string>()
  const [disolveDelay, setDisolveDelay] = useState<BigInt>(BigInt(0))
  const [stake, setStake] = useState<BigInt>(BigInt(0))
  const [neuronLoading, setNeuronLoading] = useState<boolean>(false)
  const [showScroll, setShowScroll] = useState<boolean>(false)

  const [proposalLoading, setProposalLoading] = useState<boolean>(false)

  //neuron
  const [neuron, setNeuron] = useState<Neuron>()

  const getPrincipalId = async () => {
    const principalId = (await dao.getPrincipalId()) as string
    setPrincipalId(principalId)
    console.log(principalId)
  }
  const getNeuron = async () => {
    const neuron = (await dao.getNeuron()) as Neuron
    setNeuron(neuron)
    console.log(neuron)
  }

  const createNeuron = async (stake: BigInt, disolveDelay: BigInt) => {
    try {
      setNeuronLoading(true)
      await dao.createNeuron(stake, disolveDelay)
      console.log("created neuron")
    } catch (e) {
      setNeuronLoading(false)
      alert(e)
    } finally {
      setNeuronLoading(false)
      getNeuron()
    }
  }

  async function get_all_proposals() {
    const allProposals = (await dao.get_all_proposals()) as Result_4
    setAllProposals(allProposals)
    console.log(allProposals)
  }

  const voteYes = async (proposalID: BigInt) => {
    try {
      setProposalLoading(true)
      await dao.quadratic_voting(true, proposalID)
      console.log("voted yes")
    } catch (e) {
      alert(e)
    } finally {
      setProposalLoading(false)
    }
    get_all_proposals()
  }

  // await dao.quadratic_voting(true, proposalID)

  // console.log("voted yes")
  // setProposalLoading(true)

  // get_all_proposals()

  const voteNo = async (proposalID: BigInt) => {
    try {
      setProposalLoading(true)
      await dao.quadratic_voting(false, proposalID)
      console.log("voted no")
    } catch (e) {
      alert(e)
    } finally {
      setProposalLoading(false)
      get_all_proposals()
    }
  }

  const submit_proposal = async (text: string) => {
    setShowScroll(true)
    try {
      ;(await dao.submit_proposal(text)) as string
    } catch (e) {
      alert(e)
    } finally {
      get_all_proposals()
      setShowScroll(false)
      getPageText()
    }
  }

  const getPageText = async () => {
    const pageText = (await dao.getPageText()) as string
    setPageText(pageText)
  }

  useEffect(() => {
    getPageText()
  }, [])

  useEffect(() => {
    get_all_proposals()
    getPrincipalId()
  }, [])

  useEffect(() => {
    getNeuron()
  }, [principalId])

  //set proposal id
  useEffect(() => {
    console.log(allProposals)
  }, [])

  useEffect(() => {
    setProposalLoading(false)
  }, [allProposals])

  return (
    <div className="example">
      <div className="proposal-container">
        <p
          className="pageText"
          style={{
            fontSize: "2.5em",
            color: "#A3BB98",
          }}
        >
          {pageText}
        </p>
        <span className="proposal-header">
          Submit A Proposal to change the text above 👆{" "}
        </span>

        <div className="proposal-form">
          <input
            type="text"
            placeholder="Proposal text"
            onChange={(e: any) => {
              setProposedText(e.target.value)
            }}
          />
          <button
            onClick={(e: any) => {
              submit_proposal(proposedText)
            }}
          >
            Submit proposal
          </button>
        </div>
        {showScroll ? (
          <div className="scroll-down">Scroll 👀 👇 to see your proposal</div>
        ) : (
          <div></div>
        )}
      </div>
      <div
        className="Neuron-container"
        style={{
          textAlign: "center",
          marginTop: "320px",
          marginBottom: "320px",
        }}
      >
        <span className="Neuron-header">Neuron Management</span>
        <div className="Neuron-form"></div>
        {neuronLoading ? (
          <div className="loadingspinner">
            <div id="square1"></div>
            <div id="square2"></div>
            <div id="square3"></div>
            <div id="square4"></div>
            <div id="square5"></div>
          </div>
        ) : (
          <div
            className="Neuron-form"
            style={{ fontFamily: "none", textAlign: "initial" }}
          >
            <div className="Neuron-info">
              <div className="Neuron-info-item">
                <span className="Neuron-info-item-header">PrincipalId: </span>
                <span
                  className="Neuron-info-item-value"
                  style={{ fontSize: "small" }}
                  // onClick={(e: any) => {
                  //   navigator.clipboard.
                  //   alert("Copied to clipboard")
                  // }}
                >
                  {neuron
                    ? neuron["ok"]?.ownerPrincipal
                    : "Log-in to create a neuron"}
                  {/* <img
                    src="https://img.icons8.com/ios/50/000000/copy.png"
                    style={{
                      filter: "invert(1)",
                      height: "10px",
                      padding: "5px",
                    }}
                  /> */}
                </span>
              </div>
              <div className="Neuron-info-item">
                <span className="Neuron-info-item-header">Stake: </span>
                {neuron && neuron["ok"]?.stake == 0 ? (
                  <input
                    type="text"
                    placeholder="Stake"
                    onChange={(e: any) => {
                      setStake(BigInt(e.target.value))
                    }}
                  />
                ) : (
                  <span className="Neuron-info-item-value">
                    {neuron
                      ? Number(neuron["ok"]?.stake) + " tokens"
                      : "loading"}
                  </span>
                )}
              </div>
              <div className="Neuron-info-item">
                <span className="Neuron-info-item-header">Disolve Delay: </span>
                {neuron && neuron["ok"]?.disolveDelay == 0 ? (
                  <input
                    type="text"
                    placeholder="Enter # of Months"
                    onChange={(e: any) => {
                      setDisolveDelay(BigInt(e.target.value))
                    }}
                  />
                ) : (
                  <span className="Neuron-info-item-value">
                    {neuron
                      ? Number(neuron["ok"]?.disolveDelay) / 2629800000000000 +
                        " months"
                      : "loading"}
                  </span>
                )}
              </div>
            </div>
            <button
              onClick={(e: any) => {
                createNeuron(disolveDelay, stake)
              }}
            >
              Create Neuron
            </button>
          </div>
        )}
      </div>
      <div
        className="proposal-slider"
        // style={{ padding: "padding", height: "900px", overflow: "scroll" }}
      >
        <p
          style={{
            textAlign: "center",
            padding: "5px",
            borderTop: "1px solid gray",
          }}
        >
          Proposals
        </p>
        {allProposals != undefined && !proposalLoading ? (
          allProposals["ok"].map((proposal: Proposal) => {
            return (
              <div
                className="Proposals"
                style={{
                  padding: "10px",
                  filter: proposalLoading
                    ? "grayScale(1) "
                    : "drop-shadow(0px 0px 150px white)",
                  borderBottom: "1px solid gray",
                  marginBottom: "10px",
                  height: "300px",
                  width: "300px",
                }}
              >
                <p
                  style={{
                    color: "#A3BB98",
                    textShadow: "0px 0px 100px white",
                  }}
                >
                  {" "}
                  {proposal.pageText}{" "}
                </p>
                <p style={{ fontFamily: "none" }}>
                  {" "}
                  Proposal ID: {Number(proposal.id)}{" "}
                </p>
                <p style={{ fontFamily: "none" }}>
                  {" "}
                  Proposal Status:{" "}
                  <span
                    style={{
                      color: proposal.status == "Passed" ? "#A3bb98" : "white",
                    }}
                  >
                    {proposal.status}{" "}
                  </span>
                </p>
                <div className="votebar" style={{ background: "gray" }}>
                  <div
                    className="vote-bar-yes"
                    style={{
                      color: "#A3BB98",
                      background:
                        Number(proposal.vote) < 100 ? "#A3BB98" : "#A3BB98",
                      width:
                        proposal.vote < 100 && proposal.vote > 0
                          ? `${Number(proposal.vote) + "%"}`
                          : proposal.vote > 100
                          ? "100%"
                          : "0%",
                    }}
                  >
                    <span
                      style={{
                        padding: "10px",
                        textShadow: "0px 0px 3px black",
                      }}
                    >
                      {proposal.vote && Number(proposal.vote) >= 100
                        ? "100%"
                        : proposal.vote && Number(proposal.vote) <= 0
                        ? "0%"
                        : Number(proposal.vote) + "%"}
                    </span>
                  </div>
                  <div
                    className="vote-bar-no"
                    style={{
                      color: "#A3BB98",
                      background: "white",
                      width:
                        proposal.vote < 100
                          ? 100 - Number(proposal.vote)
                          : "0%",
                    }}
                  ></div>
                </div>
                <button
                  onClick={(e: any) => {
                    voteYes(proposal.id)
                  }}
                >
                  Vote yes
                </button>
                <button
                  onClick={(e: any) => {
                    voteNo(proposal.id)
                  }}
                >
                  Vote no
                </button>
              </div>
            )
          })
        ) : (
          <div className="loadingspinner">
            <div id="square1"></div>
            <div id="square2"></div>
            <div id="square3"></div>
            <div id="square4"></div>
            <div id="square5"></div>
          </div>
        )}
      </div>
    </div>
  )
}

export { Dao }
