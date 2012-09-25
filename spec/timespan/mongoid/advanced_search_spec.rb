require 'timespan/mongoid/spec_helper'

describe TimeSpan do
  subject { account }

  before :all do
    Mongoid.logger.level = Logger::DEBUG
    Moped.logger.level = Logger::DEBUG

    Mongoid.logger = Logger.new($stdout)
    Moped.logger   = Logger.new($stdout)    
  end


  context '5 Accounts with periods serialized' do
    before do
      Account.delete_all

      @acc1 = Account.create name: '1', period: Timespan.from(:today, 5.days), 
                             time_period: TimePeriod.new(flex: (2..5).minutes)

      @acc2 = Account.create name: '2', period: Timespan.from(:today, 5.days), 
                             time_period: TimePeriod.new(flex: (2..4).minutes)

      @acc3 = Account.create name: '3', period: Timespan.from(:today, 5.days), 
                             time_period: TimePeriod.new(flex: (0..4).minutes)

      @acc4 = Account.create name: '4', period: Timespan.from(:today, 5.days), 
                             time_period: TimePeriod.new(flex: (0..3).minutes)

      @acc5 = Account.create name: '5', period: Timespan.from(:today, 5.days), 
                             time_period: TimePeriod.new(flex: (0..2).minutes)

      @acc6 = Account.create name: '6', period: Timespan.from(:next_month, 100.days), 
                             time_period: TimePeriod.new(flex: (0..2).minutes)

      @acc7 = Account.create name: '7', period: Timespan.from(:next_week, 100.days), 
                             time_period: TimePeriod.new(flex: (0..2).minutes)

      @acc8 = Account.create name: '8', period: Timespan.new(start_date: 40.days.from_now, duration: 100.days), 
                             time_period: TimePeriod.new(flex: (3..10).minutes)

      @acc9 = Account.create name: '9', period: Timespan.new(start_date: 40.days.from_now, duration: 100.days), 
                             time_period: TimePeriod.new(flex: (0..3).minutes)
    end

    describe 'ASAP 2 minutes' do
      let(:period) { 2.minutes.to_i }

      let(:criteria) do
        Account.where(:'period.from'.gte => 1.day.ago.to_i).or( {:'time_period.flex.from' => period}, {:'time_period.flex.to' => period} )
      end

      # it 'should create a flex' do
      #   (2..5).minutes.min.should == 120
      #   (2..5).minutes.should be_a DurationRange
      # end

      # it 'should have a nice criteria' do
      #   criteria.selector['$or'].should == [{"time_period.flex.from"=>120}, {"time_period.flex.to"=>120}]
      #   criteria.selector["period.from"].should be_a Hash
      # end

      it 'should find #1, #2, #3, #4, #5' do
        puts criteria.to_a
        criteria.to_a.should include @acc1, @acc2, @acc5, @acc6, @acc7
      end
    end

    describe 'ASAP 3 minutes' do
      let(:period) { 3.minutes.to_i }

      let(:criteria) do
        Account.where(:'period.from'.gte => 1.day.ago.to_i).or( {:'time_period.flex.from' => period}, {:'time_period.flex.to' => period} )
      end

      it 'should find #4, #8, #9' do
        criteria.to_a.should include(@acc4, @acc8, @acc9)
      end
    end

    describe 'ASAP 4 minutes' do
      let(:period) { 4.minutes.to_i }

      let(:criteria) do
        Account.where(:'period.from'.gte => 1.day.ago.to_i).or( {:'time_period.flex.from' => period}, {:'time_period.flex.to' => period} )
      end

      it 'should find #2, #3' do
        criteria.to_a.should include(@acc2, @acc3)
      end
    end

    # describe 'ASAP 1-4 months' do
    #   let(:min_period) { 1.month }
    #   let(:max_period) { 4.months }

    #   it 'should find #1, #2, #3, #4' do
    #     Account.where('period.from'.gte => Time.now, 'duration.from'.gte => min_period, 'duration.to'.lte => max_period) 
    #   end
    # end

    # describe 'ASAP 3-5 months' do
    #   let(:min_period) { 1.month }
    #   let(:max_period) { 4.months }

    #   it 'should find #1, #2, #3, #4' do
    #     Account.where('period.from'.gte => Time.now, 'duration.from'.gte => min_period, 'duration.to'.lte => max_period) 
    #   end
    # end

    # describe 'ASAP 5-7 months' do
    #   let(:min_period) { 1.month }
    #   let(:max_period) { 4.months }

    #   it 'should find #1' do
    #     Account.where('period.from'.gte => Time.now, 'duration.from'.gte => min_period, 'duration.to'.lte => max_period) 
    #   end
    # end

    # describe 'ASAP at least 4 months' do
    #   let(:min_period) { 1.month }

    #   it 'should find #1, #2, #3' do
    #     Account.where('period.from'.gte => Time.now, 'duration.from'.gte => min_period) 
    #   end
    # end
  end
end