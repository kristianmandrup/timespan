## 0.5.8

* Extracted experimental time-lord integration into separate file
since time-lord seems to fuck-up date calculations provided by Rails :P

## 0.5.6 - 0.5.7

* Initial support for `time-lord` gem.
* Use `xduration` 3.0.0 gem

## 0.5.5

* Better DurationRange specs
* DurationRange comparisons
* DurationRange Mongoid serialization works (and specs)

## 0.5.4

- Added subclasses LongDurationRange and ShortDurationRange for long and short durations.