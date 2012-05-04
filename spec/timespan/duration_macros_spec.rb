require 'spec_helper'
require 'duration/macros'

describe Timespan do
	subject { timespan }

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  context '3 hrs duration + 3hrs duration' do
    let(:timespan) { Timespan.new("3 hrs") + 3.dhours }

    describe '.start_date' do
      its(:start_date) { should be }
      its(:end_date) { should be }
      its(:duration) { should be_a Duration }
      specify { subject.hours.should be 6 }
    end
  end

  context '3 hrs duration + 2hrs' do
    let(:timespan) { Timespan.new("3 hrs") + 2.hours }

    describe '.start_date' do
      its(:start_date) { should be }
      its(:end_date) { should be }
      its(:duration) { should be_a Duration }
      specify { subject.hours.should be 5 }
    end
  end
end