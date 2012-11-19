require 'spec_helper'

describe Timespan::Span do
  subject { timespan }

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  describe '.asap factory method' do
    let(:timespan) { Timespan.asap :to => to }    

    its(:asap?) { should be_true }
  end

  describe '.asap=' do
    before do
      @timespan = Timespan.new :from => from, :to => to
      @timespan.asap = true
    end

    specify { @timespan.asap?.should be_true }
  end

  describe '.asap!' do
    before do
      @timespan = Timespan.new :from => from, :to => to
      @timespan.asap!
    end

    specify { @timespan.asap?.should be_true }
  end
end