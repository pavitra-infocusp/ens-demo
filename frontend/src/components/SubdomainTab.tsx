import { useState } from 'react'
import { useWriteContract } from 'wagmi'
import { ensRegistrarAbi } from '../generated'
import addresses from '../ENSContracts/addresses.json'

export function SubdomainTab() {
  const [subdomain, setSubdomain] = useState('')
  const [parentName, setParentName] = useState('')
  const [subdomainOwner, setSubdomainOwner] = useState('')

  const { writeContract: registerSubdomain, isPending } = useWriteContract()

  const handleRegisterSubdomain = () => {
    if (!subdomain || !parentName || !subdomainOwner) return
    registerSubdomain({
      address: addresses.ENSRegistrar as `0x${string}`,
      abi: ensRegistrarAbi,
      functionName: 'registerSubdomain',
      args: [subdomain, parentName, subdomainOwner as `0x${string}`]
    })
  }

  return (
    <div className="card">
      <h2>Register Subdomain</h2>
      <div className="form-group">
        <input
          type="text"
          placeholder="Subdomain name"
          value={subdomain}
          onChange={(e) => setSubdomain(e.target.value)}
        />
        <input
          type="text"
          placeholder="Parent name (without .eth)"
          value={parentName}
          onChange={(e) => setParentName(e.target.value)}
        />
        <input
          type="text"
          placeholder="Subdomain owner address"
          value={subdomainOwner}
          onChange={(e) => setSubdomainOwner(e.target.value)}
        />
        <button 
          onClick={handleRegisterSubdomain} 
          disabled={isPending || !subdomain || !parentName || !subdomainOwner}
        >
          {isPending ? 'Registering...' : 'Register Subdomain'}
        </button>
        {subdomain && parentName && (
          <p className="result">
            Will register: <strong>{subdomain}.{parentName}.eth</strong>
          </p>
        )}
      </div>
    </div>
  )
}
