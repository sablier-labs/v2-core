# Benchmarks for implementations in the LockupTranched contract

| Implementation                      | Gas Usage |
| ----------------------------------- | --------- |
| `burn`                              | 16920     |
| `cancel`                            | 64157     |
| `createWithDurations` (3 tranches)  | 236175    |
| `createWithTimestamps` (3 tranches) | 225510    |
| `renounce`                          | 28315     |
| `withdraw` (by Anyone)              | 41680     |
| `withdraw` (by Recipient)           | 51652     |
