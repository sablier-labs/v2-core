# Benchmarks for LockupDynamic

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 16898     |
| `cancel`                              | 80408     |
| `createWithDurations` (2 segments)    | 203116    |
| `createWithDurations` (10 segments)   | 418215    |
| `createWithDurations` (100 segments)  | 2907238   |
| `createWithTimestamps` (2 segments)   | 192781    |
| `createWithTimestamps` (10 segments)  | 407894    |
| `createWithTimestamps` (100 segments) | 2832399   |
| `renounce`                            | 46610     |
| `withdraw` (by Anyone)                | 57953     |
| `withdraw` (by Recipient)             | 65125     |
