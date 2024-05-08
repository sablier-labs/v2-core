# Benchmarks for LockupTranched

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 15582     |
| `cancel`                              | 59489     |
| `createWithDurations` (2 tranches)    | 188637    |
| `createWithDurations` (10 tranches)   | 383394    |
| `createWithDurations` (100 tranches)  | 2641415   |
| `createWithTimestamps` (2 tranches)   | 177653    |
| `createWithTimestamps` (10 tranches)  | 371888    |
| `createWithTimestamps` (100 tranches) | 2559515   |
| `renounce`                            | 26602     |
| `withdraw` (by Anyone)                | 36224     |
| `withdraw` (by Recipient)             | 43328     |
