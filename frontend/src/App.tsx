import { useState } from 'react'
import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { injected } from 'wagmi/connectors'
import { RegisterTab } from './components/RegisterTab'
import { SubdomainTab } from './components/SubdomainTab'
import { TransferTab } from './components/TransferTab'
import { LookupTab } from './components/LookupTab'
import { ReverseLookupTab } from './components/ReverseLookupTab'
import './App.css'

function App() {
  const [activeTab, setActiveTab] = useState('register')

  const { address: connectedAddress, isConnected } = useAccount()
  const { connect } = useConnect()
  const { disconnect } = useDisconnect()

  const tabs = [
    { id: 'register', label: 'Register Name', component: <RegisterTab /> },
    { id: 'subdomain', label: 'Register Subdomain', component: <SubdomainTab /> },
    { id: 'transfer', label: 'Transfer Name', component: <TransferTab /> },
    { id: 'lookup', label: 'Lookup Name', component: <LookupTab /> },
    { id: 'reverse', label: 'Reverse Lookup', component: <ReverseLookupTab /> }
  ]

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
          {/* Tab Navigation */}
          <div className="tabs">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                className={`tab ${activeTab === tab.id ? 'active' : ''}`}
                onClick={() => setActiveTab(tab.id)}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {/* Tab Content */}
          <div className="tab-content">
            {tabs.find(tab => tab.id === activeTab)?.component}
          </div>
        </>
      )}

      <div className="info">
        <p><strong>Note:</strong> Make sure to update contract addresses in ENSContracts/addresses.json after deployment</p>
      </div>
    </div>
  )
}

export default App
