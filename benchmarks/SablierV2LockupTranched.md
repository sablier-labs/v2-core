# Benchmarks for LockupTranched

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 15644     |
| `cancel`                              | 59218     |
| `createWithDurations` (2 tranches)    | 188074    |
| `createWithDurations` (10 tranches)   | 382980    |
| `createWithDurations` (100 tranches)  | 2642619   |
| `createWithTimestamps` (2 tranches)   | 177047    |
| `createWithTimestamps` (10 tranches)  | 371386    |
| `createWithTimestamps` (100 tranches) | 2560197   |
| `renounce`                            | 26664     |
| `withdraw` (by Anyone)                | 36001     |
| `withdraw` (by Recipient)             | 43105     |
