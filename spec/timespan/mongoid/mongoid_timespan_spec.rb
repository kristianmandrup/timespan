require 'timespan/mongoid/spec_helper'

describe Timespan do
	subject { account }

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  context '2 days duration (from now - default)' do
    let(:account) do 
      Account.create :period => {:duration => '2 days', :from => Date.today }
    end

    describe '.start_date' do
      it 'should default to today' do
        DateTime.parse(subject.period.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
      end
    end
  end
end