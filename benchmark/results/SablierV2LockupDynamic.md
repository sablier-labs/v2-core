# Benchmarks for LockupDynamic

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 15547     |
| `cancel`                              | 69677     |
| `createWithDurations` (2 segments)    | 189533    |
| `createWithDurations` (10 segments)   | 388772    |
| `createWithDurations` (100 segments)  | 2699423   |
| `createWithTimestamps` (2 segments)   | 178454    |
| `createWithTimestamps` (10 segments)  | 375791    |
| `createWithTimestamps` (100 segments) | 2600316   |
| `renounce`                            | 38863     |
| `withdraw` (by Anyone)                | 46526     |
| `withdraw` (by Recipient)             | 53630     |
