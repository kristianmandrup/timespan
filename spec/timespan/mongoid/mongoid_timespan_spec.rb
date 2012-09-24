require 'timespan/mongoid/spec_helper'

describe TimeSpan do
	subject { account }

  def tomorrow
    Date.today + 1.day
  end

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  context 'factory method #from' do
    describe ':today' do
      let(:account) do 
        Account.create period: Timespan.from(:today, 5.days)
      end

      describe '.start_date' do
        it 'should default to today' do
          DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
        end
      end

      describe '.duration' do
        it 'should be 5 days' do
          subject.period.to_days.should == 5
        end
      end

      describe '.end_date' do
        it 'should be 5 days from today' do
          DateTime.parse(subject.period.end_date.to_s).strftime('%d %b %Y').should == (Date.today + 5.days).strftime('%d %b %Y')
        end
      end
    end

    describe ':asap' do
      let(:account) do 
        Account.create period: Timespan.from(:asap, 5.days)
      end

      describe '.start_date' do
        it 'should default to today' do
          DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
        end
      end

      describe '.duration' do
        it 'should be 5 days' do
          subject.period.to_days.should == 5
        end
      end

      describe '.end_date' do
        it 'should be 5 days from today' do
          DateTime.parse(subject.period.end_date.to_s).strftime('%d %b %Y').should == (Date.today + 5.days).strftime('%d %b %Y')
        end
      end
    end

    describe ':tomorrow' do
      let(:account) do 
        Account.create period: Timespan.from(:tomorrow, 5.days)
      end

      describe '.start_date' do
        it 'should be tomorrow' do
          DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.tomorrow.strftime('%d %b %Y')
        end
      end

      describe '.duration' do
        it 'should be 5 days' do
          subject.period.to_days.should == 5
        end
      end

      describe '.end_date' do
        it 'should be 5 days from tomorrow' do
          DateTime.parse(subject.period.end_date.to_s).strftime('%d %b %Y').should == (Date.tomorrow + 5.days).strftime('%d %b %Y')
        end
      end
    end

    describe ':next_week' do
      let(:account) do 
        Account.create period: Timespan.from(:next_week, 5.days)
      end

      describe '.start_date' do
        it 'should be 1 week from today' do
          DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.next_week.strftime('%d %b %Y')
        end
      end

      describe '.duration' do
        it 'should be 5 days' do
          subject.period.to_days.should == 5
        end
      end

      describe '.end_date' do
        it 'should be 5 days from next week' do
          DateTime.parse(subject.period.end_date.to_s).strftime('%d %b %Y').should == (Date.next_week + 5.days).strftime('%d %b %Y')
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
        DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
      end
    end
  end

  context '2 days duration using Timespan' do
    let(:account) do 
      Account.create :period => Timespan.new(:duration => 2.days)
    end

    describe '.start_date' do
      it 'should default to today' do
        DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
      end
    end
  end

  context '2 days using integer via ActiveSupport::Duration' do
    let(:account) do 
      Account.create :period => Timespan.new(2.days)
    end

    describe '.start_date' do
      it 'should default to today' do
        DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
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

        subject.end_date = tomorrow + 3.days
      end

      specify do
        Date.parse(subject.time_period.end_date.to_s).should == tomorrow + 3.days
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
        Date.parse(subject.start_date.to_s).should == tomorrow
      end
    end
  end
end