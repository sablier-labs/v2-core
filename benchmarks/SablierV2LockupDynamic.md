# Benchmarks for LockupDynamic

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 15937     |
| `cancel`                              | 70591     |
| `createWithDurations` (2 segments)    | 190763    |
| `createWithDurations` (10 segments)   | 387638    |
| `createWithDurations` (100 segments)  | 2671641   |
| `createWithTimestamps` (2 segments)   | 180223    |
| `createWithTimestamps` (10 segments)  | 377456    |
| `createWithTimestamps` (100 segments) | 2600811   |
| `renounce`                            | 38829     |
| `withdraw` (by Anyone)                | 47375     |
| `withdraw` (by Recipient)             | 54452     |
