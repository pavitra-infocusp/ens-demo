import { useState } from 'react'
import { useWriteContract, useReadContract } from 'wagmi'
import { ensRegistrarAbi } from '../generated'
import addresses from '../ENSContracts/addresses.json'

export function RegisterTab() {
  const [name, setName] = useState('')
  const [address, setAddress] = useState('')

  const { writeContract: registerName, isPending } = useWriteContract()

  const { data: isAvailable } = useReadContract({
    address: addresses.ENSRegistrar as `0x${string}`,
    abi: ensRegistrarAbi,
    functionName: 'available',
    args: name ? [name] : undefined,
    query: { enabled: !!name }
  })

  const handleRegister = () => {
    if (!name || !address) return
    registerName({
      address: addresses.ENSRegistrar as `0x${string}`,
      abi: ensRegistrarAbi,
      functionName: 'register',
      args: [name, address as `0x${string}`]
    })
  }

  return (
    <div className="card">
      <h2>Register Name</h2>
      <div className="form-group">
        <input
          type="text"
          placeholder="Name to register (without .eth)"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        <input
          type="text"
          placeholder="Address to assign"
          value={address}
          onChange={(e) => setAddress(e.target.value)}
        />
        <button 
          onClick={handleRegister} 
          disabled={isPending || !name || !address}
        >
          {isPending ? 'Registering...' : 'Register Name'}
        </button>
        {name && (
          <p className="result">
            <strong>{name}.eth</strong> is {isAvailable ? 'available' : 'not available'}
          </p>
        )}
      </div>
    </div>
  )
}
