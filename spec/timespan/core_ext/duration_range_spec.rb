require 'timespan/mongoid/spec_helper'

describe Range do
  subject { timerange }

  describe 'create DurationRange' do
    let(:range) { (1..5) }
    let (:timerange) { range.days }
  
    specify { subject.should be_a DurationRange }

    its(:min) { should be_a Fixnum }
    its(:max) { should be_a Fixnum }

    specify { subject.min.should == 1.day }
    specify { subject.max.should == 5.days }
  end
end

describe DurationRange do
  subject { timerange }

  let(:range) { (1..5) }

  context 'invalid range unit' do  
    it 'should not allow invalid time unit' do
      expect { DurationRange.new range, :yuppies }.to raise_error
    end
  end

  context 'day range' do
    let (:timerange) { range.days }

    its(:range) { should be_a Range }
    its(:min) { should == 1.day }
    its(:max) { should == 5.days }
    its(:unit) { should == :days }

    specify { subject.between?(4.days).should be_true }
  end

  context 'week range' do
    let (:timerange) { range.weeks }

    its(:range) { should be_a Range }
    its(:min) { should == 1.week }
    its(:max) { should == 5.weeks }
    its(:unit) { should == :weeks }
  end

  context 'month range' do
    let (:timerange) { range.months }

    its(:min) { should == 1.month }
    its(:max) { should == 5.months }
    its(:unit) { should == :months }
  end

  context 'year range' do
    let (:timerange) { range.years }

    its(:min) { should == 1.year }
    its(:max) { should == 5.years }
    its(:unit) { should == :years }
  end
end

describe LongDurationRange do
  subject { timerange }

  let(:range) { (1..5) }

  context 'invalid range unit' do  
    it 'should not allow invalid time unit' do
      expect { LongDurationRange.new range, :hours }.to raise_error
    end
  end

  context 'valid range unit' do  
    it 'should allow valid long time unit' do
      expect { LongDurationRange.new range, :day }.to_not raise_error
    end
  end
end

describe ShortDurationRange do
  subject { timerange }

  let(:range) { (1..5) }

  context 'invalid range unit' do  
    it 'should not allow invalid time unit' do
      expect { ShortDurationRange.new range, :day }.to raise_error
    end
  end

  context 'valid range unit' do  
    it 'should allow valid long time unit' do
      expect { ShortDurationRange.new range, :hour }.to_not raise_error
    end
  end
end