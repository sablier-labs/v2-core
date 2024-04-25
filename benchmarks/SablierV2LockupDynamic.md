# Benchmarks for implementations in the LockupDynamic contract

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 16898     |
| `cancel`                              | 80408     |
| `createWithDurations` (2 segments)    | 212672    |
| `createWithDurations` (10 segments)   | 424973    |
| `createWithDurations` (100 segments)  | 2914035   |
| `createWithTimestamps` (2 segments)   | 199536    |
| `createWithTimestamps` (10 segments)  | 414651    |
| `createWithTimestamps` (100 segments) | 2839193   |
| `renounce`                            | 46588     |
| `withdraw` (by Anyone)                | 57953     |
| `withdraw` (by Recipient)             | 65125     |
