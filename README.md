# Polytrade - Smart contracts - Solidity

This project demonstrates an advanced Decentralized Invoice Finance use case, integrating other tools commonly used alongside Hardhat in the ecosystem.

The project comes with contracts, tests for those contracts, scripts that deploy contracts, it also comes with a variety of other tools, preconfigured.

Try running some of the following tasks:

```shell
npx hardhat test
npx hardhat coverage
npx hardhat compile
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check && npx solhint 'contracts/**/*.sol'
npx prettier '**/*.{json,sol,md}' --write && npx solhint 'contracts/**/*.sol' --fix
npm run lint:js && npm run lint:sol
npm run lint:js-fix && npm run lint:sol-fix
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.ts
TS_NODE_FILES=true npx ts-node scripts/deploy.ts
npx eslint '**/*.{js,ts}'
npx eslint '**/*.{js,ts}' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

# Performance optimizations

For faster runs of your tests and scripts, consider skipping ts-node's type checking by setting the environment variable `TS_NODE_TRANSPILE_ONLY` to `1` in hardhat's environment. For more details see [the documentation](https://hardhat.org/guides/typescript.html#performance-optimizations).
