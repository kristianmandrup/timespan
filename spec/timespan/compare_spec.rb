require 'spec_helper'

describe "Timespan" do
	subject { timespan }

  context 'From and To with 1 day apart' do
  	let(:timespan) { Timespan.new :from => from, :to => to}

  	let(:from) { Chronic.parse("1 day ago") }
  	let(:to)   { Time.now }

    describe '.compare == ' do    
    end

    describe '.compare < ' do    
    end    

    describe '.compare > ' do    
    end    
  end

  context 'From 2 days ago until today' do
    describe '.time_left' do
      let(:timespan) { Timespan.new :from => "2 days ago", :to => Date.today }    

      it 'should have 0 days left' do
        timespan.time_left.days.should == -0
      end
    end  

    describe '.expired?' do
      let(:timespan) { Timespan.new :from => "2 days ago", :to => Date.today }    

      it 'should have 0 days left' do
        timespan.expired?.should be_true
      end
    end  

  end  
end