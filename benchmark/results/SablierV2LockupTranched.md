# Benchmarks for LockupTranched

| Implementation                                             | Gas Usage |
| ---------------------------------------------------------- | --------- |
| `burn`                                                     | 15630     |
| `cancel`                                                   | 59537     |
| `createWithDurations` (2 tranches) (Broker fee set)        | 198148    |
| `createWithDurations` (2 tranches) (Broker fee not set)    | 187055    |
| `createWithDurations` (10 tranches) (Broker fee set)       | 385315    |
| `createWithDurations` (10 tranches) (Broker fee not set)   | 394243    |
| `createWithDurations` (100 tranches) (Broker fee set)      | 2646302   |
| `createWithDurations` (100 tranches) (Broker fee not set)  | 2760279   |
| `createWithTimestamps` (2 tranches) (Broker fee set)       | 188274    |
| `createWithTimestamps` (2 tranches) (Broker fee not set)   | 182548    |
| `createWithTimestamps` (10 tranches) (Broker fee set)      | 394311    |
| `createWithTimestamps` (10 tranches) (Broker fee not set)  | 389062    |
| `createWithTimestamps` (100 tranches) (Broker fee set)     | 2715385   |
| `createWithTimestamps` (100 tranches) (Broker fee not set) | 2709090   |
| `renounce`                                                 | 26650     |
| `withdraw` (2 segments) (After End Time) (by Recipient)    | 20246     |
| `withdraw` (2 segments) (Before End Time) (by Recipient)   | 15063     |
| `withdraw` (2 segments) (After End Time) (by Anyone)       | 15142     |
| `withdraw` (2 segments) (Before End Time) (by Anyone)      | 14759     |
| `withdraw` (10 segments) (After End Time) (by Recipient)   | 18001     |
| `withdraw` (10 segments) (Before End Time) (by Recipient)  | 19946     |
| `withdraw` (10 segments) (After End Time) (by Anyone)      | 17697     |
| `withdraw` (10 segments) (Before End Time) (by Anyone)     | 19642     |
| `withdraw` (100 segments) (After End Time) (by Recipient)  | 46904     |
| `withdraw` (100 segments) (Before End Time) (by Recipient) | 75039     |
| `withdraw` (100 segments) (After End Time) (by Anyone)     | 46600     |
| `withdraw` (100 segments) (Before End Time) (by Anyone)    | 74735     |
