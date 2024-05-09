# Benchmarks for LockupTranched

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 15582     |
| `cancel`                              | 59489     |
| `createWithDurations` (2 tranches)    | 198147    |
| `createWithDurations` (10 tranches)   | 388107    |
| `createWithDurations` (100 tranches)  | 2646156   |
| `createWithTimestamps` (2 tranches)   | 182362    |
| `createWithTimestamps` (10 tranches)  | 376598    |
| `createWithTimestamps` (100 tranches) | 2564248   |
| `renounce`                            | 26602     |
| `withdraw` (by Anyone)                | 36224     |
| `withdraw` (by Recipient)             | 43328     |
