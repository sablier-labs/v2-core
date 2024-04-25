# Benchmarks for implementations in the LockupTranched contract

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 16920     |
| `cancel`                              | 64157     |
| `createWithDurations` (2 tranches)    | 200365    |
| `createWithDurations` (10 tranches)   | 404429    |
| `createWithDurations` (100 tranches)  | 2767114   |
| `createWithTimestamps` (2 tranches)   | 190270    |
| `createWithTimestamps` (10 tranches)  | 395249    |
| `createWithTimestamps` (100 tranches) | 2703747   |
| `renounce`                            | 28315     |
| `withdraw` (by Anyone)                | 41680     |
| `withdraw` (by Recipient)             | 48852     |
