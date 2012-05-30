require 'spec_helper'

describe "Timespan" do
	subject { timespan }

  context 'From and To with 2 day apart' do
  	let(:timespan) { Timespan.new :from => from, :to => to}

  	let(:from) { 2.days.ago }
  	let(:to)   { Time.now }

    describe 'Compare' do
      describe '==' do  
      	specify do 
      		(subject == 2.days).should be_true
      	end  
      end

      describe '<' do    
      	specify do 
      		(subject < 2.day).should be_false
      	end

        specify do 
          (subject < 3.days).should be_true
        end
      end    

      describe '>' do    
      	specify do 
      		(subject > 2.day).should be_false
      	end

        specify do 
          (subject > 1.day).should be_true
        end
      end

      describe '>=' do    
        specify do 
          (subject >= 2.days).should be_true
        end
      end

      describe '<=' do    
        specify do 
          (subject <= 2.days).should be_true
        end
      end

      describe 'between? dates' do    
        specify do 
          subject.between?(2.days.ago, 1.minute.from_now).should be_true
        end

        specify do 
          subject.between?(Time.now, 1.day.from_now).should be_false
        end
      end

      describe 'between? durations' do    
        specify do 
          subject.between?(1.days, 3.days).should be_true
        end

        specify do 
          subject.between?(3.days, 4.days).should be_false
        end
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