## ERC (Foundry) — README

This repository contains a small ERC-style token implementation and a suite of Forge/Foundry tests. It uses common testing libraries such as `ds-test` and `forge-std` and includes convenient testing utilities under `src/test/utils`.

This README describes the repository layout, how tests are structured (the "parent" patterns used in tests), and commands to build, lint and run the test-suite.

## Quick start

Prerequisites:

- Foundry (forge/cast) installed and on your PATH. See https://book.getfoundry.sh/
- Node/npm for lint tooling (optional).

Initialize and run:

```bash
# clone (if you haven't) and initialize submodules
git submodule update --init --recursive

# install npm dev tools used for linting (optional)
npm install

# build contracts
forge build

# run tests
forge test -v
```

## Repository layout (important files)

- `src/` — main Solidity source files
	- `ERC20.sol` — the token implementation under test
	- `test/` — test contracts and testing utilities
		- `ERC20.t.sol` — comprehensive test suite for the token
		- `utils/Utilities.sol` — helper contract used to create test accounts and set balances
		- `utils/Console.sol` — simple logging helper used in tests
- `lib/` — git submodules and third-party libraries
	- `forge-std/` — cheatcodes, helpers and standard test utilities
	- `ds-test/` — low level test primitives (asserts, DSTest)
	- `openzeppelin-contracts/`, `solmate/` — other libraries (present for reference)
- `remappings.txt` — import remappings used by Foundry
- `package.json` — scripts for linting (`prettier`, `solhint`)

## Testing pattern and "parent" used in tests

The tests in `src/test/ERC20.t.sol` follow a small inheritance-based setup pattern to share common setup and helper functions across test suites. Key points:

- Base test contract: `BaseSetup` extends `DSTest` and also inherits the token contract (in this repo `MyToken` / `ERC20`). This lets tests call token functions directly (e.g., `this.transfer(...)`) while still receiving DSTest assertions.
- Utilities: `Utilities.sol` creates a set of test users (addresses) and funds them with ETH; tests use this to simulate accounts such as `Alice` and `Bob`.
- Cheatcodes and Vm: The tests import `Vm` from `forge-std` and create an instance using the `HEVM_ADDRESS` constant provided by foundry/forge. Example pattern used here:

```solidity
import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";

contract BaseSetup is DSTest {
		Vm internal immutable _vm = Vm(HEVM_ADDRESS);
		// ...
		function setUp() public virtual {
				_vm.label(alice, "Alice");
				_vm.prank(user);
				_vm.expectRevert(abi.encodePacked("some revert message"));
		}
}
```

Notes:

- `HEVM_ADDRESS` is a special constant injected by Forge that points to the cheatcode contract. Wrapping it with `Vm(HEVM_ADDRESS)` gives you access to cheat methods such as `prank`, `label`, `expectRevert`, etc.
- An alternative (convenience) is to import `forge-std/Test.sol` and inherit `Test` which already exposes a `vm` instance. This repo currently demonstrates manual `Vm` usage (via `HEVM_ADDRESS`) combined with `DSTest` assertions.

## Common commands

- Build contracts

```bash
forge build
```

- Run tests (verbose)

```bash
forge test -v
```

- Lint and format (prettier + solhint configured in `package.json`)

```bash
npm run prettier
npm run solhint
```

## Tips & gotchas

- If you see compiler errors like `Cannot call function via contract type name` when using `Vm.label(...)`, make sure you're calling the method on an instance (for example `vm.label(...)` or `_vm.label(...)`) not on the `Vm` type itself.
- To use the simpler `vm` global instance, import and inherit `forge-std/Test.sol` instead of manually instantiating `Vm`.
- Keep `remappings.txt` up to date if you change submodule locations.

## Contributing

Contributions and test improvements are welcome. Please follow the repository's lint rules and add tests for any behavior you change.

## License

Check individual library licenses under `lib/` (e.g., `forge-std`, `ds-test`, `openzeppelin-contracts`). The root project follows the template's license (see other top-level files).

---

If you'd like, I can also:

- switch tests to use `forge-std/Test.sol` and the `vm` global (simpler pattern), or
- add a short CONTRIBUTING.md and a minimal test run CI workflow.

Tell me which follow-up you'd prefer.
