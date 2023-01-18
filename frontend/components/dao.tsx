import { useCanister } from "@connect2ic/react"
import React, { useEffect, useState } from "react"

const Dao = () => {
  /*
   * This how you use canisters throughout your app.
   */
  const [dao] = useCanister("dao")
  const [pageText, setPageText] = useState<string>()

  //   const refreshCounter = async () => {
  //     const freshCount = await counter.getValue() as bigint
  //     setCount(freshCount)
  //   }

  const getPageText = async () => {
    const pageText = (await dao.getPageText()) as string
    setPageText(pageText)
  }

  useEffect(() => {
    getPageText()
  }, [])

  return (
    <div className="example">
      <p style={{ fontSize: "2.5em" }}>{pageText}</p>
    </div>
  )
}

export { Dao }
