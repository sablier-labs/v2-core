# Benchmarks for implementations in the LockupDynamic contract

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 16898     |
| `cancel`                              | 80408     |
| `createWithDurations` (2 segments)    | 203117    |
| `createWithDurations` (10 segments)   | 418215    |
| `createWithDurations` (100 segments)  | 2907239   |
| `createWithTimestamps` (2 segments)   | 192781    |
| `createWithTimestamps` (10 segments)  | 407894    |
| `createWithTimestamps` (100 segments) | 2832400   |
| `renounce`                            | 46588     |
| `withdraw` (by Anyone)                | 57953     |
| `withdraw` (by Recipient)             | 65125     |
