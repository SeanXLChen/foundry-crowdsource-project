import { ethers } from "./ethers-6.7.esm.min.js"
import { abi, contractAddress } from "./constants.js"

const connectButton = document.getElementById("connectButton")
const withdrawButton = document.getElementById("withdrawButton")
const fundButton = document.getElementById("fundButton")
// const balanceButton = document.getElementById("balanceButton")
// const getOwnerButton = document.getElementById("getOwnerButton")

connectButton.onclick = connect
withdrawButton.onclick = withdraw
fundButton.onclick = fund
// balanceButton.onclick = getBalance
// getOwnerButton.onclick = getOwner

// Add at the top with other DOM elements
const connectedAddressSpan = document.getElementById("connectedAddress")

// Add automatic fetching of owner and balance when page loads
window.addEventListener('load', async () => {
  await getOwner()
  await getBalance()
  
  // Check if already connected
  if (typeof window.ethereum !== "undefined") {
      try {
          const accounts = await ethereum.request({ method: "eth_accounts" })
          if (accounts.length > 0) {
              connectedAddressSpan.innerHTML = accounts[0]
              connectButton.innerHTML = "Connected"
          }
      } catch (error) {
          console.log(error)
      }
  }
})

// Updated connect function
async function connect() {
  if (typeof window.ethereum !== "undefined") {
      try {
          const accounts = await ethereum.request({ method: "eth_requestAccounts" })
          const connectedAddress = accounts[0]
          connectButton.innerHTML = "Connected"
          connectedAddressSpan.innerHTML = connectedAddress
          console.log("Connected to:", connectedAddress)
          
          // Refresh info after connection
          await getOwner()
          await getBalance()

          // Add listener for account changes
          window.ethereum.on('accountsChanged', function (accounts) {
              if (accounts.length > 0) {
                  connectedAddressSpan.innerHTML = accounts[0]
              } else {
                  connectedAddressSpan.innerHTML = "Not connected"
                  connectButton.innerHTML = "Connect Wallet"
              }
          })

      } catch (error) {
          console.log(error)
          connectButton.innerHTML = "Error connecting"
          connectedAddressSpan.innerHTML = "Connection failed"
      }
  } else {
      connectButton.innerHTML = "Please install MetaMask"
      connectedAddressSpan.innerHTML = "MetaMask not found"
  }
}

async function getOwner() {
    if (typeof window.ethereum !== "undefined") {
        const provider = new ethers.BrowserProvider(window.ethereum)
        const contract = new ethers.Contract(contractAddress, abi, provider)
        try {
            const ownerAddress = await contract.getOwner()
            document.getElementById("ownerAddress").innerHTML = ownerAddress
            console.log("Owner address:", ownerAddress)
        } catch (error) {
            console.log(error)
            document.getElementById("ownerAddress").innerHTML = "Error fetching owner"
        }
    }
}

async function getBalance() {
    if (typeof window.ethereum !== "undefined") {
        const provider = new ethers.BrowserProvider(window.ethereum)
        try {
            const balance = await provider.getBalance(contractAddress)
            const formattedBalance = ethers.formatEther(balance)
            document.getElementById("contractBalance").innerHTML = formattedBalance
            console.log("Balance:", formattedBalance)
        } catch (error) {
            console.log(error)
            document.getElementById("contractBalance").innerHTML = "Error fetching balance"
        }
    }
}

async function fund() {
    const ethAmount = document.getElementById("ethAmount").value
    console.log(`Funding with ${ethAmount}...`)
    if (typeof window.ethereum !== "undefined") {
        const provider = new ethers.BrowserProvider(window.ethereum)
        await provider.send('eth_requestAccounts', [])
        const signer = await provider.getSigner()
        const contract = new ethers.Contract(contractAddress, abi, signer)
        try {
            const transactionResponse = await contract.fund({
                value: ethers.parseEther(ethAmount),
            })
            await transactionResponse.wait(1)
            // Refresh balance after funding
            await getBalance()
        } catch (error) {
            console.log(error)
        }
    } else {
        fundButton.innerHTML = "Please install MetaMask"
    }
}

async function withdraw() {
    console.log(`Withdrawing...`)
    if (typeof window.ethereum !== "undefined") {
        const provider = new ethers.BrowserProvider(window.ethereum)
        await provider.send('eth_requestAccounts', [])
        const signer = await provider.getSigner()
        const contract = new ethers.Contract(contractAddress, abi, signer)
        try {
            console.log("Processing transaction...")
            const transactionResponse = await contract.withdraw()
            await transactionResponse.wait(1)
            console.log("Done!")
            // Refresh balance after withdrawal
            await getBalance()
        } catch (error) {
            console.log(error)
        }
    } else {
        withdrawButton.innerHTML = "Please install MetaMask"
    }
}