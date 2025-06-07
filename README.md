# Contract DApp Voting

> 🔗 Smart contracts for a decentralized voting system built with Foundry and Solidity.

---

## 📦 Repository Structure

```
contract-dapp-voting/
├── src/
│   ├── Voting.sol           # Main voting contract with core functionality
│   └── VotingSession.sol    # Session data structures and logic
├── script/
│   └── Voting.s.sol         # Deployment scripts
├── test/
│   ├── Voting.t.sol         # Test cases for voting contract
│   └── VotingSession.t.sol  # Test cases for session functionality
├── lib/
│   ├── forge-std            # Foundry standard library
│   └── openzeppelin-contracts # OpenZeppelin contracts
├── foundry.toml            # Foundry configuration
└── README.md               # (this file)
```
---

## 🔗 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/contract-dapp-voting.git
cd contract-dapp-voting
```

### 2. Install dependencies

The project uses [Foundry](https://getfoundry.sh/) as development framework.

```bash
# Install Foundry if you haven't already
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install
```

### 3. Compile the contracts

```bash
forge build
```

---

## 🧩 How It Works

The voting system consists of these main components:

### Session Management

- Admin can create voting sessions with specified start and end times
- Each session has a unique ID and tracks its initialization state

### Candidate Registration

- Admin registers candidates by address and name for specific sessions
- Events are emitted to allow oracles to sync candidate data with off-chain systems

### Voter Eligibility

- Admin updates voter eligibility based on off-chain data (e.g., attendance)
- Oracle systems can help automate eligibility verification

### Voting Process

- Eligible voters can cast votes during open sessions
- One vote per voter per session to ensure fairness

### Results & Winner Calculation

- Vote counts are tracked on-chain and visible in real-time
- After session ends, a winner is determined based on highest vote count

## ⚙️ Testing

Run the test suite with:

```bash
forge test
```

For more verbose output:

```bash
forge test -vvv
```

## 🚀 Deployment

### 1. Set up environment

Create a `.env` file in the project root:

```
SEPOLIA_RPC_URL=your_sepolia_rpc_url
PRIVATE_KEY=your_private_key
```

### 2. Deploy to testnet (Sepolia)

```bash
source .env
forge script script/Voting.s.sol:DeployVoting --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```