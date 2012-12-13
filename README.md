# Timespan

Use Timespans in Ruby :)

Will calculate time diff between two dates, then allow you to get the time difference in some time unit as a number.

```ruby
	t = Timespan.new(:start => Date.today, :duration => 3.days)
	t.to_days # => 3
	t.to_weeks # => 0
	t.to_secs # => 259200
	t.to_hours = 10800

  t = Timespan.new("2 days") # from today
  t = Timespan.new(2.days) # from today
  t = Timespan.new(200) # 200 secs from today
  t = Timespan.new(duration: 2.days) # specific use of :duration option

  t = Timespan.new("3 hrs").from(2.days.from_now)

  t = Timespan.new(:from => 2.days.ago)

  t = Timespan.new(:end_date => 4.days.from_now)

	t = Timespan.new(:from => Date.today, :to => "6 weeks from now")	

	t = Timespan.new(:from => Date.today, :duration => "7 weeks 3 days")	
	t = Timespan.new(:from => 2.days.ago, :duration => "5 months and 2 weeks")	
```

See specs for more examples of usage

## Comparison

```ruby
timespan.between?(2.days.ago, 1.minute.from_now)
timespan.between?(1.days, 3.days)
timespan < 3.days
```

## Math

```ruby
3_days_more = timespan + 3.days
day_less = timespan -1 3.day
```

## Spanner

Internally Timespan uses Spanner to parse duration strings.

`Spanner.parse('23 hours 12 minutes')

## Duration (ruby-duration)

```ruby
Duration.new(100) => #<Duration: minutes=1, seconds=40, total=100>
Duration.new(:hours => 5, :minutes => 70) => #<Duration: hours=6, minutes=10, total=22200>

Duration.new(:weeks => 3, :days => 1).format("%w %~w and %d %~d") => "3 weeks and 1 day"
Duration.new(:weeks => 1, :days => 20).format("%w %~w and %d %~d") => "3 weeks and 6 days"
```

Duration locale file

```yaml
da:
  ruby_duration:
    second: sekond
    seconds: sekonder
    minute: minut
    minutes: minutter
    hour: time
    hours: timer
    day: dag
    days: dage
    week: uge
    weeks: uges
    month: måned
    months: måneder
    year: år
    years: år
```

Duration datatype for Mongoid

```ruby
require 'duration/mongoid'

class MyModel
  include Mongoid::Document
  field :duration, type => Duration
end
```

## Timespan i18n

Timespan locale file

```yaml
da:
  timespan:
    from: fra
    to: til
    lasting: der varer ialt
```

## Timespan for Mongoid

Tested and works with Mongoid 2.4 and 3.0+

Custom Timespan datatype:

`Mongoid::Timespanned` adds the following class level macros:

* `timespan_methods target, *names`
* `timespan_delegates target, *names`
* `timespan_delegate name, target = :period`
* `timespan_setters target, *names`
* `timespan_setter target, name`

* `timespan_container_delegates container, timespan_field, *names`
* `timespan_container_delegate container, timespan_field, name`

Note that all the macros, take an `options` Hash as the last argument, where you can set `override: true` in order to override any existing methods. Otherwise an `ArgumentError` exception will be raised, to warn you of a method name conflict!

```ruby
require 'timespan/mongoid'

class Account
  include Mongoid::Document
  include Mongoid::Timespanned

  field :period, :type => Timespan

  timespan_methods :period

  embeds_one :time_period
  timespan_container_delegates :time_period, :dates, :start, :end  
end

class TimePeriod
  include Mongoid::Document
  include Mongoid::Timespanned

  field :dates, :type => ::Timespan, :between => true

  embedded_in :account

  timespan_methods :dates
end
```

Note: See `mongoid_timespan_spec.rb` for more examples of usage, and also see the `ClassMethods` module in `timespanned.rb` :)

Usage example:

```ruby
account = Account.create :period => {:duration => '2 days', :from => Date.today }

account.period.start_date
account.period.end_date
account.period.days
account.period.duration # => Duration

# using timespan setters defined by timespan_methods
account.period_start = tomorrow
account.period_end = 5.days.from_now

# using timespan delegates defined by timespan_methods
account.start_date == tomorrow
account.end_date == tomorrow

# using timespan_container_delegates on time_period
account.start_date = tomorrow
account.end_date = tomorrow + 5.days
```

## Factory method

Timespan now has the class level factory methods `#from` and `#untill`. 

### From

```ruby
account = Account.create :period => Timespan.from :tomorrow, 7.days

# today
Timespan.from :today, 7.days

# now
Timespan.from :asap, 7.days
Timespan.from :now, 7.days

# now
Timespan.from :today, 7.days

# starting one week from today
Timespan.from :next_week, 7.days

# starting first day next week
Timespan.from :next_week, 7.days, start: true

# starting first day next month
Timespan.from :next_month, 7.days, start: true
```

### Untill

Creates timespan from `Time.now` until the time specified.

```ruby
Timespan.untill :tomorrow
Timespan.untill :next_week
Timespan.untill :next_month, start: true
Timespan.untill 2.days.from_now
```

## Searching periods

```ruby
Account.where(:'period.from'.lt => 6.days.ago.to_i)
Account.where(:'period.from'.gt => 3.days.ago.to_i)

# in range
Account.where(:'period.from'.gt => 3.days.ago.to_i, :'period.to'.lt => Time.now.utc.to_i)
```

Make it easier by introducing a class helper:

```ruby
class Account
  include Mongoid::Document
  field :period, :type => Timespan

  def self.between from, to
    Account.where(:'period.from'.gt => from.to_i, :'period.to'.lte => to.to_i)
  end
end
```

`Account.between(6.days.ago, 1.day.ago)`

Alternatively auto-generate a `#between` helper for the field:

```ruby
class Account
  include Mongoid::Document
  field :period, :type => TimeSpan, :between => true
```

`Account.period_between(6.days.ago, 1.day.ago)`

See the `mongoid_search_spec.rb` for examples:

## Chronic duration

Is used to parse duration strings if Spanner can't be handle it

`ChronicDuration.parse('4 minutes and 30 seconds')

### Endure

Use the 'endure' gem based on the old "days_and_times".

See: [days_and_times](https://github.com/kristianmandrup/days_and_times)

Currently it also uses Duration, which conflicts with the 'ruby-duration' gem.

```
  1.day #=> A duration of 1 day
  7.days #=> A duration of 7 days
  1.week #=> A duration of 1 week
  1.week - 2.days #=> A duration of 5 days
  1.week.from(Now()) #=> The time of 1 week from this moment
  1.week.from(Today()) #=> The time of 1 week from the beginning of today
  3.minutes.ago.until(7.minutes.from(Now())) #=> duration 3 minutes ago to 7 minutes from now
  3.minutes.ago.until(7.minutes.from(Now())) - 2.minutes #=> duration 3 minutes ago to 5 minutes from now
  4.weeks.from(2.days.from(Now())).until(8.weeks.from(Yesterday())) #=> A duration, starting in 4 weeks and 2 days, and ending 8 weeks from yesterday
  1.week - 1.second #=> A duration of 6 days, 23 hours, 59 minutes, and 59 seconds
  4.weeks / 2 #=> A duration of 2 weeks
  4.weeks / 2.weeks #=> The integer 2
  8.weeks.each {|week| ...} #=> Runs code for each week contained in the duration (of 8 weeks)
  8.weeks.starting(Now()).each {|week| ...} #=> Runs code for each week in the duration, but each week is also anchored to a starting time, in sequence through the duration.
  1.week.each {|week| ...} #=> Automatically chooses week as its iterator
  7.days.each {|day| ...} #=> Automatically chooses day as its iterator
  1.week.each_day {|day| ...} #=> Forcing the week to iterate through days
  1.week.each(10.hours) {|ten_hour_segment| ...} #=> Using a custom iterator of 10 hours. There would be 17 of them, but notice that the last iteration will only be 8 hours.
``

## Configuration and overrides

Timespan by default uses `Time.now.utc` to set the current time, fx used when either `end_date` or `start_date` otherwise would be nil. This is used in order to work with Mongoid (see [issue #400](https://github.com/mongoid/mongoid/issues/400))

You can customize `now` to return fx `Time.now`, `Date.today` or whatever suits you.

```ruby
class Timespan
  def now
    Time.now # or Date.today
  end
end
```

By default the `TimeSpan` is stored using `:from` and `:to` for the start and end times. This can be customized as follows: 

```ruby
TimeSpan.start_field = :start
TimeSpan.end_field = :end
```

## Ranges

A Range can be converted into either a `Timespan` or a `DurationRange`

### DurationRange

```ruby
dr = (1..5).days # => DurationRange 1..5, :days
ts =(1..5).days(:timespan) # => Timespan start_date: 1.day.from_now, end_date: 5.days.from_now

dr.between?(4.days) # => true
```

You can also use Range#intersect from *sugar-high* gem to test intersection of time ranges ;)

## Client side helpers

This gem now includes som javascript assets to assist in performing date and timespan (duration) calculations on the client side also:

* `moment.js` (1.7.2)
* `date_ext.js` DP_DateExtensions
* `timespan.js`

### Example usage

```javascript
Date.timeleft("12/10/2012", "07/05/2013");
```

```javascript
Date.timeleft(Date.create("12/10/2012"), "07/05/2013");
```

Aliases for timeleft are: `duration` and `timespan`.

See the javascript source for the full API or check out http://momentjs.com/docs/ and http://depressedpress.com/javascript-extensions/dp_dateextensions/.

Note: timeleft was extracted from (http://www.proglogic.com/code/javascript/time/timeleft.php)

To use these assets with the Asset pipeline, simply add this to your `application.js` or similar manifest file :) (after jquery which is required!)

```javascript
//= require moment.js
//= require date_ext.js
//= require timespan.js
```

### Timespan

## Contributing to Timespan
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Kristian Mandrup. See LICENSE.txt for
further details.

