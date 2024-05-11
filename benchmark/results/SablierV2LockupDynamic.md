# Benchmarks for LockupDynamic

| Implementation                                             | Gas Usage |
| ---------------------------------------------------------- | --------- |
| `burn`                                                     | 15595     |
| `cancel`                                                   | 69725     |
| `createWithDurations` (2 segments) (Broker fee set)        | 199044    |
| `createWithDurations` (2 segments) (Broker fee not set)    | 193772    |
| `createWithDurations` (10 segments) (Broker fee set)       | 390700    |
| `createWithDurations` (10 segments) (Broker fee not set)   | 405754    |
| `createWithDurations` (100 segments) (Broker fee set)      | 2704451   |
| `createWithDurations` (100 segments) (Broker fee not set)  | 2829521   |
| `createWithTimestamps` (2 segments) (Broker fee set)       | 183208    |
| `createWithTimestamps` (2 segments) (Broker fee not set)   | 178496    |
| `createWithTimestamps` (10 segments) (Broker fee set)      | 380547    |
| `createWithTimestamps` (10 segments) (Broker fee not set)  | 376376    |
| `createWithTimestamps` (100 segments) (Broker fee set)     | 2606711   |
| `createWithTimestamps` (100 segments) (Broker fee not set) | 2602990   |
| `renounce`                                                 | 38911     |
| `withdraw` (2 segments) (After End Time) (by Recipient)    | 19064     |
| `withdraw` (2 segments) (Before End Time) (by Recipient)   | 27735     |
| `withdraw` (2 segments) (After End Time) (by Anyone)       | 13960     |
| `withdraw` (2 segments) (Before End Time) (by Anyone)      | 27431     |
| `withdraw` (10 segments) (After End Time) (by Recipient)   | 14264     |
| `withdraw` (10 segments) (Before End Time) (by Recipient)  | 32678     |
| `withdraw` (10 segments) (After End Time) (by Anyone)      | 13960     |
| `withdraw` (10 segments) (Before End Time) (by Anyone)     | 32374     |
| `withdraw` (100 segments) (After End Time) (by Recipient)  | 14264     |
| `withdraw` (100 segments) (Before End Time) (by Recipient) | 88561     |
| `withdraw` (100 segments) (After End Time) (by Anyone)     | 13960     |
| `withdraw` (100 segments) (Before End Time) (by Anyone)    | 88257     |
