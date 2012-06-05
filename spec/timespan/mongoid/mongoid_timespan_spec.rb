require 'timespan/mongoid/spec_helper'

describe TimeSpan do
	subject { account }

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
  end
end