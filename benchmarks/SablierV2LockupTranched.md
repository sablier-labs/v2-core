# Benchmarks for LockupTranched

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 16920     |
| `cancel`                              | 64157     |
| `createWithDurations` (2 tranches)    | 200319    |
| `createWithDurations` (10 tranches)   | 404384    |
| `createWithDurations` (100 tranches)  | 2767068   |
| `createWithTimestamps` (2 tranches)   | 190270    |
| `createWithTimestamps` (10 tranches)  | 395249    |
| `createWithTimestamps` (100 tranches) | 2703746   |
| `renounce`                            | 28337     |
| `withdraw` (by Anyone)                | 41680     |
| `withdraw` (by Recipient)             | 48852     |
