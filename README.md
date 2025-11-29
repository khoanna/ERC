# ERC (Foundry) — Smart Contract Development & Auditing

This repository contains ERC-style token implementations (ERC20, ERC721, ERC777, ERC1155) and an ERC-4337 account abstraction implementation, with comprehensive Forge/Foundry tests. The project is configured for professional development with integrated testing, linting, and security auditing using Slither.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Security Auditing with Slither](#security-auditing-with-slither)
- [Testing Patterns](#testing-patterns)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

1. **Foundry (Forge/Cast/Anvil)**

   - Installation: `curl -L https://foundry.paradigm.xyz | bash`
   - Then run: `foundryup`
   - Verify: `forge --version`
   - Documentation: https://book.getfoundry.sh/

2. **Python 3.8+** (for Slither)

   - Check version: `python3 --version`
   - Most systems have Python pre-installed

3. **pip** (Python package manager)
   - Usually comes with Python
   - Verify: `pip3 --version`

### Optional Tools

4. **Node.js & npm** (for Solidity linting)
   - Version 14+ recommended
   - Download: https://nodejs.org/

## Installation & Setup

### Step 1: Clone and Initialize

```bash
# Clone the repository
git clone <your-repo-url>
cd foundry

# Initialize git submodules (required for dependencies)
git submodule update --init --recursive
```

### Step 2: Install Foundry Dependencies

Foundry automatically manages Solidity dependencies via git submodules. The key libraries are:

- `forge-std` - Testing utilities and cheatcodes
- `ds-test` - Basic testing primitives
- `openzeppelin-contracts` - Standard token implementations
- `account-abstraction` - ERC-4337 implementation
- `solmate` - Gas-optimized contracts

```bash
# Build all contracts (this also checks dependencies)
forge build
```

### Step 3: Install Slither (Security Analyzer)

```bash
# Install Slither via pip
pip3 install slither-analyzer

# Verify installation
slither --version

# Alternative: Install with additional features
pip3 install slither-analyzer[all]
```

If you encounter permission issues, use:

```bash
pip3 install --user slither-analyzer
```

### Step 4: Install Node.js Dependencies (Optional - for linting)

```bash
# Install prettier and solhint for code formatting
npm install
```

### Step 5: Verify Installation

```bash
# Test Foundry installation
forge test -vv

# Test Slither installation
slither --help
```

## Project Structure

```
foundry/
├── src/                          # Smart contract source code
│   ├── ERC20.sol                # ERC20 token implementation
│   ├── ERC721.sol               # NFT implementation
│   ├── ERC777.sol               # Advanced token with hooks
│   ├── ERC1155.sol              # Multi-token standard
│   ├── ERC4337/                 # Account abstraction
│   │   └── SimpleAccount.sol    # ERC-4337 smart account
│   ├── script/                  # Deployment scripts
│   └── test/                    # Test contracts
│       ├── ERC20.t.sol          # ERC20 tests
│       ├── ERC4337.t.sol        # ERC-4337 tests
│       └── utils/               # Test utilities
│           ├── Utilities.sol    # Helper functions (create users, etc.)
│           └── Console.sol      # Logging utilities
├── lib/                         # Dependencies (git submodules)
│   ├── forge-std/              # Foundry standard library
│   ├── ds-test/                # Testing framework
│   ├── openzeppelin-contracts/ # OpenZeppelin library
│   ├── account-abstraction/    # ERC-4337 contracts
│   └── solmate/                # Gas-optimized contracts
├── out/                        # Compiled artifacts (auto-generated)
├── cache/                      # Build cache (auto-generated)
├── remappings.txt              # Import path mappings
├── foundry.toml                # Foundry configuration
├── package.json                # Node.js dependencies (linting)
└── README.md                   # This file
```

## Development Workflow

### Building Contracts

```bash
# Compile all contracts
forge build

# Force recompile everything
forge build --force

# Compile with specific solc version
forge build --use 0.8.24

# Show detailed compilation output
forge build -vvv
```

### Running Tests

```bash
# Run all tests
forge test

# Run with verbosity (show gas usage, logs)
forge test -vv

# Run very verbose (show stack traces)
forge test -vvv

# Run specific test contract
forge test --match-contract ERC20Test

# Run specific test function
forge test --match-test testTransferAllTokens

# Run tests with gas report
forge test --gas-report

# Watch mode (rerun on file changes)
forge test --watch
```

### Coverage Analysis

```bash
# Generate coverage report
forge coverage

# Generate detailed lcov report
forge coverage --report lcov

# Generate HTML coverage report (requires lcov)
forge coverage --report lcov && genhtml lcov.info --output-directory coverage
```

### Code Formatting & Linting

```bash
# Format Solidity files with prettier
npm run prettier

# Check formatting without writing
npm run prettier:check

# Run solhint linter
npm run solhint

# Run both prettier and solhint
npm run lint

# Check without fixing
npm run lint:check
```

## Security Auditing with Slither

Slither is a powerful static analysis framework that detects vulnerabilities, optimization issues, and code quality problems in Solidity.

### Basic Slither Commands

```bash
# Analyze entire project
slither .

# Analyze specific contract
slither src/ERC20.sol

# Analyze with specific Solc version
slither . --solc-remaps @openzeppelin=lib/openzeppelin-contracts

# Show only high and medium severity issues
slither . --filter-paths "lib|test" --exclude-informational --exclude-optimization

# Generate detailed report
slither . --print human-summary
```

### Recommended Slither Workflow

1. **Initial Full Scan** (includes all issues):

```bash
slither . --filter-paths "lib/" --exclude-dependencies
```

2. **Focus on Critical Issues**:

```bash
slither . --filter-paths "lib|test" --exclude-low --exclude-informational --exclude-optimization
```

3. **Check Specific Detectors**:

```bash
# Check for reentrancy
slither . --detect reentrancy-eth,reentrancy-no-eth

# Check for access controls
slither . --detect suicidal,arbitrary-send-eth

# Check for integer issues
slither . --detect divide-before-multiply,weak-prng
```

4. **Generate JSON Report** (for CI/CD):

```bash
slither . --json slither-report.json --filter-paths "lib|test"
```

### Understanding Slither Output

Slither categorizes issues by severity:

- 🔴 **High**: Critical vulnerabilities (reentrancy, access control)
- 🟡 **Medium**: Important issues (unchecked return values, dangerous operations)
- 🟢 **Low**: Minor issues (naming conventions, unused variables)
- ℹ️ **Informational**: Code quality suggestions
- ⚡ **Optimization**: Gas optimization opportunities

### Common Slither Detectors

| Detector              | Description                   | Severity      |
| --------------------- | ----------------------------- | ------------- |
| `reentrancy-eth`      | Reentrancy vulnerabilities    | High          |
| `arbitrary-send-eth`  | Unprotected Ether sends       | High          |
| `suicidal`            | Unprotected selfdestruct      | High          |
| `uninitialized-state` | Uninitialized state variables | High          |
| `tx-origin`           | Dangerous use of tx.origin    | Medium        |
| `unchecked-transfer`  | Unchecked ERC20 transfers     | Medium        |
| `locked-ether`        | Contracts that lock Ether     | Medium        |
| `naming-convention`   | Naming convention violations  | Informational |
| `solc-version`        | Incorrect Solidity version    | Informational |

### Slither Configuration

Create `.slither.json` in project root for custom configuration:

```json
{
  "filter_paths": "lib/|test/",
  "exclude_informational": false,
  "exclude_low": false,
  "exclude_medium": false,
  "exclude_high": false,
  "solc_remaps": [
    "@openzeppelin=lib/openzeppelin-contracts",
    "forge-std=lib/forge-std/src",
    "ds-test=lib/ds-test/src"
  ]
}
```

### Integration with CI/CD

Example GitHub Actions workflow (`.github/workflows/audit.yml`):

```yaml
name: Security Audit

on: [push, pull_request]

jobs:
  slither:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: recursive

      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1

      - name: Install Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.10"

      - name: Install Slither
        run: pip3 install slither-analyzer

      - name: Run Slither
        run: slither . --filter-paths "lib|test" --json slither-report.json || true

      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: slither-report
          path: slither-report.json
```

## Testing Patterns

This project uses an inheritance-based test structure with shared setup logic.

### Test Architecture

```solidity
// Base test contract with shared setup
contract BaseSetup is DSTest {
  Vm internal immutable _vm = Vm(HEVM_ADDRESS);
  Utilities internal _utils;
  address payable[] internal _users;
  address internal _alice;
  address internal _bob;

  function setUp() public virtual {
    _utils = new Utilities();
    _users = _utils.createUsers(5);
    _alice = _users[0];
    _bob = _users[1];

    // Label addresses for better trace output
    _vm.label(_alice, "Alice");
    _vm.label(_bob, "Bob");
  }
}

// Specific test suite inherits base setup
contract TokenTest is BaseSetup {
  function setUp() public override {
    BaseSetup.setUp();
    // Additional setup specific to this test suite
  }
}

```

### Cheatcodes and Vm Interface

The tests use Foundry's `Vm` interface for advanced testing capabilities:

- **HEVM_ADDRESS**: Special constant that points to Foundry's cheatcode contract
- `vm.prank(address)`: Sets msg.sender for the next call
- `vm.deal(address, uint)`: Sets ETH balance
- `vm.label(address, string)`: Labels address in traces
- `vm.expectRevert(bytes)`: Expects next call to revert
- `vm.startPrank(address)`: Sets msg.sender for multiple calls (until stopPrank)

Example:

```solidity
function testTransfer() public {
  vm.prank(_alice); // Next call will have msg.sender = _alice
  token.transfer(_bob, 100);
  assertEq(token.balanceOf(_bob), 100);
}

```

### Key Testing Utilities

**Utilities.sol** provides helper functions:

- `createUsers(uint256)`: Creates multiple funded test accounts
- `createUser(string)`: Creates a single labeled user

**Console.sol** provides logging:

- `console.log("message")`: Print to test output

### Assertions Available

From DSTest:

- `assertEq(a, b)`: Assert equality
- `assertEqDecimal(a, b, decimals)`: Assert with decimal formatting
- `assertTrue(condition)`: Assert boolean true
- `assertFalse(condition)`: Assert boolean false
- `assertGt(a, b)`: Assert a > b
- `assertLt(a, b)`: Assert a < b

## Troubleshooting

### Common Issues and Solutions

#### 1. "Undeclared identifier" errors

**Problem**: Contract functions showing as undeclared even though they exist.

**Solutions**:

- Ensure parent contract is not `abstract` if you're trying to instantiate it
- Change `private` visibility to `internal` for variables accessed in child contracts
- Verify import paths in `remappings.txt`
- Restart Solidity language server in VS Code

Example fix:

```solidity
// ❌ Wrong: private variables not accessible in child contracts
contract BaseSetup is DSTest {
  SimpleAccount private _account;
}

// ✅ Correct: use internal
contract BaseSetup is DSTest {
  SimpleAccount internal _account;
}

```

#### 2. "Cannot call function via contract type name"

**Problem**: Trying to call instance methods on a type.

**Solution**: Call on an instance, not the type:

```solidity
// ❌ Wrong
Vm.label(address, "label");

// ✅ Correct
vm.label(address, "label");
```

#### 3. Submodule/dependency issues

**Problem**: Missing dependencies or "file not found" errors.

**Solutions**:

```bash
# Update all submodules
git submodule update --init --recursive --remote

# If submodules are broken, clean and reinit
git submodule deinit --all -f
git submodule update --init --recursive
```

#### 4. Slither cannot find contracts

**Problem**: Slither fails with "No contract found" or import errors.

**Solutions**:

```bash
# Ensure forge build works first
forge build

# Run slither with explicit remappings
slither . --foundry-out-directory out

# Check your remappings.txt file is correct
cat remappings.txt
```

#### 5. "Function state mutability can be restricted to view"

**Problem**: Warning that function can be more restrictive.

**Solution**: Add `view` or `pure` modifier if function doesn't modify state:

```solidity
// Before
function getOwner() public returns (address) {
  return _owner;
}

// After
function getOwner() public view returns (address) {
  return _owner;
}

```

#### 6. Test functions marked as view but fail

**Problem**: Test function marked `view` but uses assertions.

**Solution**: Remove `view` modifier - DSTest assertions modify state:

```solidity
// ❌ Wrong
function testTransfer() public view {
  assertEq(balance, 100); // Error: modifies state
}

// ✅ Correct
function testTransfer() public {
  assertEq(balance, 100);
}

```

## Repository Information

- **Testing Framework**: DSTest + Forge Standard Library
- **Solidity Version**: ^0.8.24 (configurable per contract)
- **License**: Check individual contract licenses
- **Dependencies**: Managed via git submodules

## Useful Commands Reference

```bash
# Development
forge build                          # Compile contracts
forge test                           # Run tests
forge test -vvv                      # Run with max verbosity
forge coverage                       # Coverage report
forge fmt                            # Format Solidity files

# Security
slither .                            # Run security analysis
slither . --checklist                # Generate audit checklist
slither . --print human-summary      # Print contract summary

# Deployment (example)
forge create src/ERC20.sol:MyToken \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --constructor-args "MyToken" "MTK"

# Gas Analysis
forge test --gas-report              # Show gas usage
forge snapshot                       # Save gas snapshot
forge snapshot --diff                # Compare gas changes

# Debugging
forge test --debug <test_name>       # Interactive debugger
forge inspect <contract> abi         # Show contract ABI
forge inspect <contract> bytecode    # Show bytecode
```

## Additional Resources

- [Foundry Book](https://book.getfoundry.sh/) - Complete Foundry documentation
- [Slither Documentation](https://github.com/crytic/slither) - Slither usage guide
- [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- [ERC Standards](https://eips.ethereum.org/erc) - Official EIP repository
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/) - Battle-tested implementations

## Contributing

When contributing:

1. Run `forge test` to ensure all tests pass
2. Run `npm run lint` to check code style
3. Run `slither .` to check for security issues
4. Add tests for new features
5. Update documentation as needed

## License

See individual contract files for license information. Common licenses in this project:

- MIT: Most custom implementations
- GPL-3.0: Account abstraction contracts
- Multiple: OpenZeppelin and library contracts

---

**Need help?** Open an issue or check the troubleshooting section above.
