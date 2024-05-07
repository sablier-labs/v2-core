# Benchmarks for LockupTranched

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 15959     |
| `cancel`                              | 60030     |
| `createWithDurations` (2 tranches)    | 189598    |
| `createWithDurations` (10 tranches)   | 382023    |
| `createWithDurations` (100 tranches)  | 2613757   |
| `createWithTimestamps` (2 tranches)   | 179327    |
| `createWithTimestamps` (10 tranches)  | 372986    |
| `createWithTimestamps` (100 tranches) | 2554133   |
| `renounce`                            | 26286     |
| `withdraw` (by Anyone)                | 36792     |
| `withdraw` (by Recipient)             | 43869     |
