# Timespan

Use TimeSpans in Ruby :)

Will calculate time diff in milliseconds between to dates, then allow you to get the time difference in some time unit as a number.

```ruby
	t = TimeSpan.new(:start => Date.today, :duration => 3.days.ago)
	t.to_days # => 3
	t.to_weeks # => 0
	t.to_secs # => 259200
	t.to_hours = 10800

	t = TimeSpan.new(:from => Date.today, :to => "6 weeks from now")	

	t = TimeSpan.new(:from => Date.today, :duration => "7 weeks 3 days")	
	t = TimeSpan.new(:from => 2.days.ago, :duration => "5 months and 2 weeks")	
```

See specs for more examples of usage

## TODO

* use Duration for duration calculations!
* Calculate start_time and end_time based on duration if not set explicitly!

## Contributing to timespan
 
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

