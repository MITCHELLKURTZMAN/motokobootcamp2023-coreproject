import { useCanister } from "@connect2ic/react"
import React, { useEffect, useState } from "react"

const Dao = () => {
  /*
   * This how you use canisters throughout your app.
   */
  const [dao] = useCanister("dao")
  const [pageText, setPageText] = useState<string>()
  const [allProposals, setAllProposals] = useState<[string]>()
  const [proposalID, setProposalID] = useState<string>()
  const [proposalStatus, setProposalStatus] = useState<string>()
  const [proposedText, setProposedText] = useState<string>()
  const [votePercent, setVotePercent] = useState<string>()
  const [voteYesOrNo, setVoteYesOrNo] = useState<string>()
  const [voteId, setVoteId] = useState<string>()

  const get_all_proposals = async () => {
    const all_proposals = (await dao.get_all_proposals()) as [string]

    setAllProposals(all_proposals)
    setProposalID(all_proposals[0])
    console.log(all_proposals)
    console.log(all_proposals[0])
  }

  const submit_proposal = async () => {
    const submit_proposal = (await dao.submit_proposal()) as string
  }

  const vote = async () => {
    const vote = (await dao.vote()) as string
  }

  const getPageText = async () => {
    const pageText = (await dao.getPageText()) as string
    setPageText(pageText)
  }

  useEffect(() => {
    getPageText()
  }, [])

  return (
    <div className="example">
      <p className="pageText" style={{ fontSize: "2.5em" }}>
        {pageText}
      </p>
      <p className="warning" style={{ fontSize: "1em" }}></p>
      <button onClick={get_all_proposals}>Get All Proposals</button>
      <div className="proposals">
        <span> proposalID: {proposalID} </span>
      </div>
      <div>
        <input
          type="text"
          placeholder="Proposed Text"
          onChange={(e) => setProposedText(e.target.value)}
        />
        <button onClick={submit_proposal}>Submit Proposal</button>
      </div>
      <div>
        <input
          type="checkbox"
          placeholder="Vote Yes or No"
          onChange={(e) => setVoteYesOrNo(e.target.value)}
        />
        <span>check to approve</span>
      </div>
    </div>
  )
}

export { Dao }
