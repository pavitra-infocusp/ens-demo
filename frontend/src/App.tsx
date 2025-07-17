import { useState } from 'react'
import { useAccount, useConnect, useDisconnect, useWriteContract, useReadContract } from 'wagmi'
import { injected } from 'wagmi/connectors'
import { ENS_REGISTRAR_ABI, CONTRACT_ADDRESSES } from './contracts'
import './App.css'

function App() {
  const [name, setName] = useState('')
  const [address, setAddress] = useState('')
  const [lookupName, setLookupName] = useState('')
  const [lookupAddress, setLookupAddress] = useState('')
  const [transferName, setTransferName] = useState('')
  const [transferTo, setTransferTo] = useState('')
  const [subdomain, setSubdomain] = useState('')
  const [parentName, setParentName] = useState('')
  const [subdomainOwner, setSubdomainOwner] = useState('')

  const { address: connectedAddress, isConnected } = useAccount()
  const { connect } = useConnect()
  const { disconnect } = useDisconnect()
  const { writeContract, isPending } = useWriteContract()

  // Read contract data
  const { data: resolvedAddress } = useReadContract({
    address: CONTRACT_ADDRESSES.ENS_REGISTRAR as `0x${string}`,
    abi: ENS_REGISTRAR_ABI,
    functionName: 'resolve',
    args: [lookupName],
    query: { enabled: lookupName.length > 0 }
  })

  const { data: reverseName } = useReadContract({
    address: CONTRACT_ADDRESSES.ENS_REGISTRAR as `0x${string}`,
    abi: ENS_REGISTRAR_ABI,
    functionName: 'reverseLookup',
    args: [lookupAddress as `0x${string}`],
    query: { enabled: lookupAddress.length > 0 }
  })

  const handleRegister = () => {
    if (!name || !address) return
    writeContract({
      address: CONTRACT_ADDRESSES.ENS_REGISTRAR as `0x${string}`,
      abi: ENS_REGISTRAR_ABI,
      functionName: 'register',
      args: [name, address as `0x${string}`]
    })
  }

  const handleTransfer = () => {
    if (!transferName || !transferTo) return
    writeContract({
      address: CONTRACT_ADDRESSES.ENS_REGISTRAR as `0x${string}`,
      abi: ENS_REGISTRAR_ABI,
      functionName: 'transfer',
      args: [transferName, transferTo as `0x${string}`]
    })
  }

  const handleRegisterSubdomain = () => {
    if (!subdomain || !parentName || !subdomainOwner) return
    writeContract({
      address: CONTRACT_ADDRESSES.ENS_REGISTRAR as `0x${string}`,
      abi: ENS_REGISTRAR_ABI,
      functionName: 'registerSubdomain',
      args: [subdomain, parentName, subdomainOwner as `0x${string}`]
    })
  }

  return (
    <div className="container">
      <h1>ENS Demo - Core Functionality</h1>
      
      {/* Connection Status */}
      <div className="card">
        <h2>Wallet Connection</h2>
        {isConnected ? (
          <div>
            <p>Connected: {connectedAddress}</p>
            <button onClick={() => disconnect()}>Disconnect</button>
          </div>
        ) : (
          <button onClick={() => connect({ connector: injected() })}>
            Connect Wallet
          </button>
        )}
      </div>

      {isConnected && (
        <>
          {/* Register Name */}
          <div className="card">
            <h2>1. Register a Name</h2>
            <div className="form-group">
              <input
                type="text"
                placeholder="Name (e.g., alice)"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
              <input
                type="text"
                placeholder="Owner Address"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
              />
              <button onClick={handleRegister} disabled={isPending}>
                {isPending ? 'Registering...' : 'Register Name'}
              </button>
            </div>
          </div>

          {/* Register Subdomain */}
          <div className="card">
            <h2>2. Register a Subdomain</h2>
            <div className="form-group">
              <input
                type="text"
                placeholder="Subdomain (e.g., www)"
                value={subdomain}
                onChange={(e) => setSubdomain(e.target.value)}
              />
              <input
                type="text"
                placeholder="Parent Name (e.g., alice)"
                value={parentName}
                onChange={(e) => setParentName(e.target.value)}
              />
              <input
                type="text"
                placeholder="Subdomain Owner Address"
                value={subdomainOwner}
                onChange={(e) => setSubdomainOwner(e.target.value)}
              />
              <button onClick={handleRegisterSubdomain} disabled={isPending}>
                {isPending ? 'Registering...' : 'Register Subdomain'}
              </button>
            </div>
          </div>

          {/* Transfer Name */}
          <div className="card">
            <h2>3. Transfer a Name</h2>
            <div className="form-group">
              <input
                type="text"
                placeholder="Name to transfer"
                value={transferName}
                onChange={(e) => setTransferName(e.target.value)}
              />
              <input
                type="text"
                placeholder="New Owner Address"
                value={transferTo}
                onChange={(e) => setTransferTo(e.target.value)}
              />
              <button onClick={handleTransfer} disabled={isPending}>
                {isPending ? 'Transferring...' : 'Transfer Name'}
              </button>
            </div>
          </div>

          {/* Lookup Name to Address */}
          <div className="card">
            <h2>4. Lookup Name → Address</h2>
            <div className="form-group">
              <input
                type="text"
                placeholder="Name to lookup"
                value={lookupName}
                onChange={(e) => setLookupName(e.target.value)}
              />
              {resolvedAddress && (
                <p className="result">
                  <strong>{lookupName}.eth</strong> → {resolvedAddress}
                </p>
              )}
            </div>
          </div>

          {/* Reverse Lookup Address to Name */}
          <div className="card">
            <h2>5. Reverse Lookup Address → Name</h2>
            <div className="form-group">
              <input
                type="text"
                placeholder="Address to lookup"
                value={lookupAddress}
                onChange={(e) => setLookupAddress(e.target.value)}
              />
              {reverseName && (
                <p className="result">
                  <strong>{lookupAddress}</strong> → {reverseName}.eth
                </p>
              )}
            </div>
          </div>
        </>
      )}

      <div className="info">
        <p><strong>Note:</strong> Make sure to update contract addresses in contracts.ts after deployment</p>
      </div>
    </div>
  )
}

export default App
