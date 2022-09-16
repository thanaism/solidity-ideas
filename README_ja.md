# solidity-ideas

Solidityでの実装アイデアや、使ったことのなかったシンタックス・機能を試した結果をストックするリポジトリです。

# 主なコントラクト

- `StakingV2.sol`：NFTをステーキングする（保有し続ける）と、対応するFTが貯まっていく実装です。
- `RemoveInvalidValues.dol`：配列の中から条件を満たさない全ての要素をO(N)で削除する実装です。削除はunstableのため、元の順序は維持されません。
- `HighOrderFunc.sol`：意外なことにSolidityは高階関数に対応しているようです。関数の引数に関数を取る実装です。
