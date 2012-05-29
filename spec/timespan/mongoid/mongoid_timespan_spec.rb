require 'timespan/mongoid/spec_helper'

describe Timespan do
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

  context '2 days duration using :duration => integer via ActiveSupport::Duration' do
    let(:account) do 
      Account.create :period => {:duration => 2.days }
    end

    describe '.start_date' do
      it 'should default to today' do
        DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
      end
    end
  end

  context '2 days using integer via ActiveSupport::Duration' do
    let(:account) do 
      Account.create :period => 2.days
    end

    describe '.start_date' do
      it 'should default to today' do
        DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
      end
    end
  end

  context '2 days duration using string' do
    let(:account) do 
      Account.create :period => {:duration => '2 days'}
    end

    describe '.start_date' do
      it 'should default to today' do
        DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
      end
    end
  end

  context '2 days duration (from 1 day ago)' do
    let(:account) do 
      Account.create :period => {:duration => '2 days', :from => from }
    end

    describe '.start_date' do
      it 'should default to today' do
        DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == 1.day.ago.strftime('%d %b %Y') 
      end
    end
  end
end