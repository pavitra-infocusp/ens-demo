import { useState } from 'react'
import { useReadContract } from 'wagmi'
import { ensRegistrarAbi } from '../generated'
import addresses from '../ENSContracts/addresses.json'

export function LookupTab() {
  const [lookupName, setLookupName] = useState('')

  const { data: resolvedAddress, isLoading } = useReadContract({
    address: addresses.ENSRegistrar as `0x${string}`,
    abi: ensRegistrarAbi,
    functionName: 'resolve',
    args: lookupName ? [lookupName] : undefined,
    query: { enabled: !!lookupName }
  })

  return (
    <div className="card">
      <h2>Lookup Name → Address</h2>
      <div className="form-group">
        <input
          type="text"
          placeholder="Name to lookup (without .eth)"
          value={lookupName}
          onChange={(e) => setLookupName(e.target.value)}
        />
        {isLoading && <p>Loading...</p>}
        {lookupName && resolvedAddress && (
          <p className="result">
            <strong>{lookupName}.eth</strong> → {resolvedAddress}
          </p>
        )}
        {lookupName && !isLoading && !resolvedAddress && (
          <p className="result">
            <strong>{lookupName}.eth</strong> → Not found
          </p>
        )}
      </div>
    </div>
  )
}
