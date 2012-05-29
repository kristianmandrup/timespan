require 'spec_helper'

describe Timespan do
  subject { timespan }

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  context 'End date only - use Today as from (start_date)' do
    let(:timespan) { Timespan.new :to => 1.day.from_now}

    describe '.start_date' do
      it 'should default to today' do
        DateTime.parse(subject.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
      end
    end

    describe '.duration' do
      specify { subject.duration.should_not be_nil }

      it 'should be 1 day' do
        subject.to_d.should == 1
      end
    end    
  end

  context 'Start date only - use Today as to (end_date)' do
    let(:timespan) { Timespan.new :from => 1.day.ago}

    describe '.end_date' do
      it 'should default to today' do
        DateTime.parse(subject.end_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
      end
    end

    describe '.duration' do
      specify { subject.duration.should_not be_nil }

      it 'should be 1 day' do
        subject.to_d.should == 1
      end
    end
  end
end