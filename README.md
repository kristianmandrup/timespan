# Timespan

Use Timespans in Ruby :)

Will calculate time diff between two dates, then allow you to get the time difference in some time unit as a number.

```ruby
	t = Timespan.new(:start => Date.today, :duration => 3.days.ago)
	t.to_days # => 3
	t.to_weeks # => 0
	t.to_secs # => 259200
	t.to_hours = 10800

  t = Timespan.new("2 days") # from today

  t = Timespan.new("3 hrs").from(2.days.from_now)

	t = Timespan.new(:from => Date.today, :to => "6 weeks from now")	

	t = Timespan.new(:from => Date.today, :duration => "7 weeks 3 days")	
	t = Timespan.new(:from => 2.days.ago, :duration => "5 months and 2 weeks")	
```

See specs for more examples of usage

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

Custom Timespan datatype

```ruby
require 'timespan/mongoid'

class Account
  include Mongoid::Document
  field :period, :type => TimeSpan
end
```

Usage example:

```ruby
account = Account.create :period => {:duration => '2 days', :from => Date.today }

account.period.start_date
account.period.end_date
account.period.days
account.period.duration # => Duration

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

