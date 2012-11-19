require 'timespan/mongoid/spec_helper'

Mongoid::Timespanned.log = true
load_models!

describe TimeSpan do
  subject { account }

  def tomorrow
    Date.today + 1.day
  end

  def format_date date
    DateTime.parse(date.to_s).strftime('%d %b %Y')
  end  

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  context 'Mongoid' do
    describe 'DurationRange'

    let(:account) do 
      Account.create_it! 2.days, (0..3).minutes
    end

    describe 'set new start_date' do

      specify do
        subject.period_start = tomorrow
        subject.period_end = tomorrow + 5.days

        subject.time_period.dates_end = tomorrow + 3.days
        subject.end_date = tomorrow + 3.days

        subject.time_period.flex = (0..3).minutes


        # puts "time period: #{subject.time_period}"
        
        # puts "period: #{subject.period}"

        # puts "time period"
        # puts "dates: #{subject.time_period.dates}"
        # puts "flex: #{subject.time_period.flex}"

        format_date(subject.period.start_date).should == format_date(tomorrow)
      end
    end
  end
end