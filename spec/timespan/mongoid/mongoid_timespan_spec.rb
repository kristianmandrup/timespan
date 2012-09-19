require 'timespan/mongoid/spec_helper'

describe TimeSpan do
	subject { account }

  def tomorrow
    Date.today + 1.day
  end

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

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

    describe 'set new start_date' do
      before :each do
        subject.period_start = tomorrow
      end

      specify do
        subject.start_date.should == subject.period.start_date
      end

      specify do
        Date.parse(subject.start_date.to_s).should == tomorrow
      end
    end
  end
end