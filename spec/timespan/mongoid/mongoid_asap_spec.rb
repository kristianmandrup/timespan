require 'timespan/mongoid/spec_helper'

Mongoid::Timespanned.log = true
load_models!

describe TimeSpan do
  subject { account }

  def tomorrow
    @tmrw ||= today + 1.day
  end

  def today
    @today ||= Date.today
  end

  def format_date date
    DateTime.parse(date.to_s).strftime('%d %b %Y')
  end

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  # context 'Timespan.from' do
  #   let(:account) do 
  #     Account.create period: Timespan.from(:asap, 5.days)
  #   end

  #   describe ':asap' do

  #     before :all do
  #       # puts subject.period.inspect
  #     end

  #     describe 'state' do        
  #       specify { subject.period.asap?.should be_true }
  #     end

  #     describe '.start_date' do
  #       it 'should default to today' do
  #         format_date(subject.period.start_date).should == format_date(today)
  #       end
  #     end

  #     describe '.duration' do
  #       it 'should be 5 days' do
  #         subject.period.to_days.should == 5
  #       end
  #     end

  #     describe '.end_date' do
  #       it 'should be 5 days from today' do
  #         format_date(subject.period.end_date).should == format_date(today + 5.days)
  #       end
  #     end
  #   end

  #   context 'Timespan.asap' do
  #     let(:account) do 
  #       Account.create period: Timespan.asap(duration: 5.days)
  #     end

  #     describe ':asap' do
  #       before :all do
  #         # puts subject.period.inspect
  #       end

  #       describe 'state' do        
  #         specify { subject.period.asap?.should be_true }
  #       end
  #     end
  #   end

  context 'Timespan.new' do
    let(:account) do 
      Account.create period: Timespan.new(duration: 5.days)
    end

    describe ':asap' do
      before :all do
        subject.asap_for :period
        puts subject.period.inspect
      end

      it 'should update asap' do      
        subject.period.asap?.should be_true
      end
    end
  end
end