require 'spec_helper'

describe Timespan do
	subject { timespan }

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  context '2 days duration (from now - default)' do
    let(:timespan) { Timespan.new :duration => "2 days"}

    describe '.start_date' do
      it 'should default to today' do
        DateTime.parse(subject.start_date.to_s).strftime('%d %b %Y').should == Date.today.strftime('%d %b %Y')
      end
    end
  end

  context '3 hrs duration from now 2 days from now' do
    let(:timespan) { Timespan.new("3 hrs").from(2.days.from_now) }

    describe '.start_date' do
      its(:start_date) { should be }
      its(:end_date) { should be }
      its(:duration) { should be_a Duration }
    end
  end


  context 'From and To with 1 day apart' do
  	let(:timespan) { Timespan.new :from => from, :to => to}

    describe '.convert_to_time' do
      specify { subject.convert_to_time("1 day ago").to_s.should == 1.day.ago.to_s }
    end
  end

  context 'From and 3 days' do
    describe 'set with duration' do
    	let(:duration) { Duration.new(:days => 3)  }
  		let(:timespan) { Timespan.new :from => from, :duration => duration }

    	it 'should be 3 days' do
    		timespan.to_d.should == 3
    	end
    end

    describe 'set duration with String' do
  		let(:timespan)  { Timespan.new :from => from, :duration => "3 days" }

    	it 'should be 3 days' do
    		timespan.to_d.should == 3
    	end
    end

    describe 'set duration with Spanner String including and' do
  		let(:timespan)  { Timespan.new :from => from, :duration => "3 days and 2 hours" }

    	it 'should be 3 days and 2 hrs' do
    		timespan.to_h.should == (24 * 3) + 2
    	end
    end

    describe 'set start_time to new' do
      let(:timespan) { Timespan.new :from => from, :to => to }    

      before :each do
        @old_timespan = timespan.clone
        @new_timespan = timespan.clone
        @new_timespan.start_date = Chronic.parse("2 days ago")
      end

      its(:duration) { should be_a Duration }
      specify { subject.send(:dirty).should be_empty }

      it 'should have diff timespans' do
        @old_timespan.days.should_not == @new_timespan.days
      end
    end

    describe 'set end_time to new' do
      let(:timespan) { Timespan.new :from => from, :to => to }    

      before :each do
        @old_timespan = timespan.clone
        @new_timespan = timespan.clone
        @new_timespan.end_date = Chronic.parse("5 days from now")
      end

      its(:duration) { should be_a Duration }
      specify { subject.send(:dirty).should be_empty }

      it 'should have diff timespans' do
        @old_timespan.days.should_not == @new_timespan.days
      end
    end
  end
end
