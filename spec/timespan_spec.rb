require 'spec_helper'
require 'chronic'

describe "Timespan" do
	subject { timespan }

	let(:timespan) { Timespan.new :from => from, :to => to}

	let(:from) { Chronic.parse("1 day ago") }
	let(:to)   { Time.now }

  describe '.convert_to_time' do
    specify { subject.convert_to_time("1 day ago").to_s.should == 1.day.ago.to_s }
  end

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

		it 'should have diff timespans' do
			@old_timespan.to_d.should_not == @new_timespan.to_d
		end
  end  

  describe '.time_left' do
    let(:timespan) { Timespan.new :from => "2 days ago", :to => Date.today }    

    it 'should have -2 days left timespans' do
      timespan.time_left.days.should == -2
    end
  end  

end
