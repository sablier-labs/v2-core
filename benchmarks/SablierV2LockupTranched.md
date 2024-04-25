# Benchmarks for implementations in the LockupTranched contract

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 16920     |
| `cancel`                              | 64157     |
| `createWithDurations` (2 tranches)    | 209920    |
| `createWithDurations` (10 tranches)   | 411188    |
| `createWithDurations` (100 tranches)  | 2773898   |
| `createWithTimestamps` (2 tranches)   | 197025    |
| `createWithTimestamps` (10 tranches)  | 402005    |
| `createWithTimestamps` (100 tranches) | 2710529   |
| `renounce`                            | 28315     |
| `withdraw` (by Anyone)                | 41680     |
| `withdraw` (by Recipient)             | 48852     |
