import { http, createConfig } from 'wagmi'
import { foundry } from 'wagmi/chains'

export const config = createConfig({
  chains: [foundry],
  transports: {
    [foundry.id]: http(),
  },
})

declare module 'wagmi' {
  interface Register {
    config: typeof config
  }
}
