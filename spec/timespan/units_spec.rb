require 'spec_helper'

describe Timespan::Units do
	subject { timespan }

  context 'From and To with 1 day apart' do
  	let(:timespan) { Timespan.new :from => from, :to => to}

  	let(:from) { Chronic.parse("1 day ago") }
  	let(:to)   { Time.now }

		describe '.weeks' do
	    it "spans 0 weeks" do
	  		timespan.to_w.should == 0
	    end
	    its(:weeks) { should == 0 }
	  end

		describe '.days' do
	    it "spans 1 day" do
	  		timespan.to_d.should == 1
	    end
	    its(:days) { should == 1 }
	  end

		describe '.hours' do
	    it "spans 24 hours" do
	  		timespan.to_hrs.should == 24
	    end
	    its(:hours) { should == 24 }
	  end

		describe '.minutes' do
	    it "spans 60*24 minutes" do
	  		timespan.to_hrs.should == 24
	    end
	    its(:minutes) { should == 24*60 }
	  end

		describe '.seconds' do
	    it "spans 86400 sec" do
	  		timespan.seconds.should == 86400
	    end
	    its(:secs) { should == 86400 }
	  end

    describe '.milliseconds' do
	    it "spans 86400 sec" do
	  		timespan.milliseconds.should be_within(10).of(86400000)
	    end
	    its(:millis) { should be_within(10).of(86400000) }
	  end
  end
end