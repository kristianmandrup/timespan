require 'spec_helper'

describe "Timespan" do
	subject { timespan }

  context 'From and To with 1 day apart' do
  	let(:timespan) { Timespan.new :from => from, :to => to}

  	let(:from) { Chronic.parse("1 day ago") }
  	let(:to)   { Time.now }

    describe '.compare == ' do  
    	specify do 
    		(subject == 1.day).should be_true
    	end  
    end

    describe '.compare < ' do    
    	specify do 
    		(subject < 1.day).should be_false
    	end
    end    

    describe '.compare > ' do    
    	specify do 
    		(subject > 1.day).should be_false
    	end
    end    
  end

  context 'From 2 days ago until today' do
    let(:timespan) { Timespan.new :from => "2 days ago", :to => "1 hour ago" }    

    describe '.time_left' do
      it 'should have 0 days left' do
        timespan.time_left.days.should == 0
      end

      it 'should have 1 hour left' do
        timespan.time_left.hrs.should == -1
      end
    end  

    describe '.expired?' do
      it 'should have 0 days left' do
        timespan.expired?.should be_true
      end
    end 
  end  
end