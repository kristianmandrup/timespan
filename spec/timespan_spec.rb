require 'spec_helper'
require 'chronic'

describe "Timespan" do
	subject { timespan }

	let(:timespan) { TimeSpan.new :from => from, :to => to}

	let(:from) { Chronic.parse("1 day ago") }
	let(:to) { Time.now }

  it "spans 1 day" do
		timespan.to_d.should == 1
  end

  it "spans 86400 sec" do
		timespan.to_secs.should == 86400
  end

  it "spans 86400 sec" do
		timespan.to_mils.should be_within(10).of(86400000)
  end

  describe 'set with duration' do
  	let(:duration) { Duration.new(:days => 3)  }
		let(:timespan)  { TimeSpan.new :from => from, :duration => duration }

  	it 'should be 3 days' do
  		timespan.to_d.should == 3
  	end
  end

  describe 'set start_time to new' do
		let(:timespan) { TimeSpan.new :from => from, :to => to }  	

		before :each do
			@old_timespan = timespan.clone
			@new_timespan = timespan.clone
			@new_timespan.start_date = Chronic.parse("2 days ago")
		end

		it 'should have diff timespans' do
			@old_timespan.to_d.should_not == @new_timespan.to_d
		end
  end  
end
