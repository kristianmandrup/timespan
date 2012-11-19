require 'timespan/mongoid/spec_helper'

Mongoid::Timespanned.log = true
load_models!

describe TimeSpan do
	subject { account }

  def tomorrow
    @tmrw ||= today + 1.day
  end

  def today
    @today ||= Date.today
  end

  def format_date date
    DateTime.parse(date.to_s).strftime('%d %b %Y')
  end

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  context 'factory method #from' do
    describe ':today' do
      let(:account) do 
        Account.create period: ::Timespan.from(:today, 5.days)
      end

      describe '.to_s' do
        it 'should return a non-empty String starting with from' do      
          subject.period.to_s.should be_a String
          subject.period.to_s.should_not be_empty
          subject.period.to_s.should match(/^from/)
        end
      end

      describe '.start_date' do
        it 'should default to today' do
          format_date(subject.period.start_date).should == format_date(today)
        end
      end

      describe '.duration' do
        it 'should be 5 days' do
          subject.period.to_days.should == 5
        end
      end

      describe '.end_date' do
        it 'should be 5 days from today' do
          format_date(subject.period.end_date).should == format_date(today + 5.days)
        end
      end
    end

    describe ':tomorrow' do
      let(:account) do 
        Account.create period: Timespan.from(:tomorrow, 5.days)
      end

      describe '.start_date' do
        it 'should be tomorrow' do
          format_date(subject.period.start_date).should == format_date(Date.tomorrow)
        end
      end

      describe '.duration' do
        it 'should be 5 days' do
          subject.period.to_days.should == 5
        end
      end

      describe '.end_date' do
        it 'should be 5 days from tomorrow' do
          format_date(subject.period.end_date).should == format_date(Date.tomorrow + 5.days)
        end
      end
    end

    describe ':next_week' do
      let(:account) do 
        Account.create period: Timespan.from(:next_week, 5.days)
      end

      describe '.start_date' do
        it 'should be 1 week from today' do
          format_date(subject.period.start_date).should == format_date(Date.next_week)
        end
      end

      describe '.duration' do
        it 'should be 5 days' do
          subject.period.to_days.should == 5
        end
      end

      describe '.end_date' do
        it 'should be 5 days from next week' do
          format_date(subject.period.end_date).should == format_date(Date.next_week + 5.days)
        end
      end
    end
  end

  context '2 days duration using factory method' do
    let(:account) do 
      Account.create_it! '2 days'
    end

    describe '.start_date' do
      it 'should default to today' do
        format_date(subject.period.start_date).should == format_date(Date.today)
      end
    end
  end

  context '2 days duration using Timespan' do
    let(:account) do 
      Account.create :period => Timespan.new(:duration => 2.days)
    end

    describe '.start_date' do
      it 'should default to today' do
        format_date(subject.period.start_date).should == format_date(Date.today)
      end
    end
  end

  context '2 days using integer via ActiveSupport::Duration' do
    let(:account) do 
      Account.create :period => Timespan.new(2.days)
    end

    describe '.start_date' do
      it 'should default to today' do
        format_date(subject.period.start_date).should == format_date(Date.today)
      end
    end
  end

  context 'Setters and delegates' do
    let(:account) do 
      Account.create_it! 2.days
    end

    describe 'set new start_date' do
      before :each do
        subject.period_start = tomorrow
        subject.period_end = tomorrow + 5.days

        subject.time_period.dates_end = tomorrow + 3.days
        subject.end_date = tomorrow + 3.days
      end

      specify do
        format_date(subject.time_period.end_date).should == format_date(tomorrow + 3.days)
      end

      specify do
        subject.period.should be_a Timespan
      end

      specify do
        subject.start_date.should == subject.period.start_date
      end

      specify do
        subject.end_date.should == subject.period.end_date
      end

      specify do
        format_date(subject.start_date).should == format_date(tomorrow)
      end
    end
  end
end