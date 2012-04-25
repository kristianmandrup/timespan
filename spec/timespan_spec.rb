require 'spec_helper'
require 'chronic'

describe "Timespan" do
	subject { timespan }

	let(:timespan) { TimeSpan.new :from => from, :to => to}

	let(:from) { Chronic.parse("1 day ago") }
	let(:to) { Time.now }


	before do
		puts timespan
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

  it "less than 2 days" do
		timespan.to_d.should < (86400 * 2)
  end
end
