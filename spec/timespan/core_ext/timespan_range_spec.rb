require 'timespan/mongoid/spec_helper'

describe Range do
  subject { timerange }

  let(:range) { (1..5) }

  describe 'create TimespanRange' do
    
    let (:timerange) { range.months(:timespan) }
  
    specify { subject.should be_a TimespanRange }
    its(:range) { should be_a Timespan }
  end
end

describe TimespanRange do
  subject { timerange }

  let(:range) { (1..5) }

  context 'day range' do
    let (:timerange) { range.days(:timespan) }

    its(:range) { should be_a Timespan }
    its(:min) { should == 1.day }
    its(:max) { should == 5.days }
    its(:unit) { should == :days }
  end

  context 'week range' do
    let (:timerange) { range.weeks(:timespan) }

    its(:range) { should be_a Timespan }
    its(:min) { should == 1.week }
    its(:max) { should == 5.weeks }
    its(:unit) { should == :weeks }
  end

  context 'month range' do
    let (:timerange) { range.months(:timespan) }

    its(:range) { should be_a Timespan }
    its(:min) { should == 1.month }
    its(:max) { should == 5.months }
    its(:unit) { should == :months }
  end

  context 'year range' do
    let (:timerange) { range.years(:timespan) }

    its(:range) { should be_a Timespan }
    its(:min) { should == 1.year }
    its(:max) { should == 5.years }
    its(:unit) { should == :years }
  end
end