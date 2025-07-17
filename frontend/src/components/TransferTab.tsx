import { useState } from 'react'
import { useWriteContract } from 'wagmi'
import { ensRegistrarAbi } from '../generated'
import addresses from '../ENSContracts/addresses.json'

export function TransferTab() {
  const [transferName, setTransferName] = useState('')
  const [transferTo, setTransferTo] = useState('')

  const { writeContract: transferNameContract, isPending } = useWriteContract()

  const handleTransfer = () => {
    if (!transferName || !transferTo) return
    transferNameContract({
      address: addresses.ENSRegistrar as `0x${string}`,
      abi: ensRegistrarAbi,
      functionName: 'transfer',
      args: [transferName, transferTo as `0x${string}`]
    })
  }

  return (
    <div className="card">
      <h2>Transfer Name</h2>
      <div className="form-group">
        <input
          type="text"
          placeholder="Name to transfer (without .eth)"
          value={transferName}
          onChange={(e) => setTransferName(e.target.value)}
        />
        <input
          type="text"
          placeholder="New owner address"
          value={transferTo}
          onChange={(e) => setTransferTo(e.target.value)}
        />
        <button 
          onClick={handleTransfer} 
          disabled={isPending || !transferName || !transferTo}
        >
          {isPending ? 'Transferring...' : 'Transfer Name'}
        </button>
        {transferName && transferTo && (
          <p className="result">
            Will transfer <strong>{transferName}.eth</strong> to {transferTo}
          </p>
        )}
      </div>
    </div>
  )
}
