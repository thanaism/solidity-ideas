# solidity-ideas

This is a repository to stock implementation ideas in Solidity and the results of trying out syntax/features I have not used before.

# Main contructs.

- `StakingV2.sol`: This is an implementation where staking (holding) an NFT will accumulate the corresponding FT.
- `RemoveInvalidValues.sol`: This is an implementation that removes all elements from the array that do not satisfy the condition with O(N). The deletion is UNSTABLE, so the original order is not maintained.
- `HighOrderFunc.sol`: Surprisingly, Solidity seems to support higher-order functions. This is an implementation that takes functions as function arguments.
