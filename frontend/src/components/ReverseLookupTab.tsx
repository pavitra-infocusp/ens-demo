import { useState } from 'react'
import { useReadContract } from 'wagmi'
import { ensRegistrarAbi } from '../generated'
import addresses from '../ENSContracts/addresses.json'

export function ReverseLookupTab() {
  const [lookupAddress, setLookupAddress] = useState('')

  const { data: reverseName, isLoading } = useReadContract({
    address: addresses.ENSRegistrar as `0x${string}`,
    abi: ensRegistrarAbi,
    functionName: 'reverseLookup',
    args: lookupAddress ? [lookupAddress as `0x${string}`] : undefined,
    query: { enabled: !!lookupAddress }
  })

  return (
    <div className="card">
      <h2>Reverse Lookup Address → Name</h2>
      <div className="form-group">
        <input
          type="text"
          placeholder="Address to lookup"
          value={lookupAddress}
          onChange={(e) => setLookupAddress(e.target.value)}
        />
        {isLoading && <p>Loading...</p>}
        {lookupAddress && reverseName && (
          <p className="result">
            <strong>{lookupAddress}</strong> → {reverseName}.eth
          </p>
        )}
        {lookupAddress && !isLoading && !reverseName && (
          <p className="result">
            <strong>{lookupAddress}</strong> → No name found
          </p>
        )}
      </div>
    </div>
  )
}
