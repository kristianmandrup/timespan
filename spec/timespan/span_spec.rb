require 'spec_helper'

describe Timespan::Span do
  subject { timespan }

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  describe 'set seconds to new' do
    let(:timespan) { Timespan.new :from => from, :to => to }    

    before :each do
      @old_timespan = timespan.clone
      @new_timespan = timespan.clone
      @new_timespan.seconds = 120
    end

    its(:duration) { should be_a Duration }
    specify { subject.send(:dirty).should be_empty }

    it 'should have diff durations' do
      @old_timespan.duration.should_not == @new_timespan.duration
    end

    it 'should have diff timespans in minutes' do
      @old_timespan.minutes.should_not == @new_timespan.minutes
    end    
  end

  describe 'set minutes to new' do
    let(:timespan) { Timespan.new :from => from, :to => to }    

    before :each do
      @old_timespan = timespan.clone
      @new_timespan = timespan.clone
      @new_timespan.minutes = 50
    end

    its(:duration) { should be_a Duration }
    specify { subject.send(:dirty).should be_empty }

    it 'should have diff durations' do
      @old_timespan.duration.should_not == @new_timespan.duration
    end

    it 'should have diff timespans in minutes' do
      @old_timespan.minutes.should_not == @new_timespan.minutes
    end    
  end

  describe 'set duration to new' do
    let(:timespan) { Timespan.new :from => from, :to => to }    

    before :each do
      @old_timespan = timespan.clone
      @new_timespan = timespan.clone
      @new_timespan.duration = "7 days"
    end

    its(:duration) { should be_a Duration }
    specify { subject.send(:dirty).should be_empty }

    it 'should have diff timespans' do
      @old_timespan.days.should_not == @new_timespan.days
    end
  end
end