# Benchmarks for LockupDynamic

| Implementation                        | Gas Usage |
| ------------------------------------- | --------- |
| `burn`                                | 15609     |
| `cancel`                              | 69406     |
| `createWithDurations` (2 segments)    | 188964    |
| `createWithDurations` (10 segments)   | 388327    |
| `createWithDurations` (100 segments)  | 2700328   |
| `createWithTimestamps` (2 segments)   | 177842    |
| `createWithTimestamps` (10 segments)  | 375259    |
| `createWithTimestamps` (100 segments) | 2600701   |
| `renounce`                            | 38925     |
| `withdraw` (by Anyone)                | 46303     |
| `withdraw` (by Recipient)             | 53407     |
