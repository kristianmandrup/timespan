require 'timespan/mongoid/spec_helper'

describe TimeSpan do
  subject { account }

  before :all do
    # Mongoid.logger.level = Logger::DEBUG
    # Moped.logger.level = Logger::DEBUG
    # Mongoid.logger = Logger.new($stdout)
    # Moped.logger   = Logger.new($stdout)    
  end

  def max_asap
    10.days.from_now.to_i
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

      @acc8 = Account.create name: '8', period: Timespan.new(start_date: 9.days.from_now, duration: 100.days), 
                             time_period: TimePeriod.new(flex: (5..10).minutes)

      @acc9 = Account.create name: '9', period: Timespan.new(start_date: 40.days.from_now, duration: 100.days), 
                             time_period: TimePeriod.new(flex: (0..3).minutes)

      @acc8 = Account.create name: '10', period: Timespan.new(start_date: 1.week.from_now, duration: 100.days), 
                             time_period: TimePeriod.new(flex: (3..6).minutes)
    end

    def yesterday
      1.day.ago.to_i
    end

    def where_hash
      {:'period.from'.gte => yesterday, :'period.from'.lte => max_asap}
    end

    def exactly
      [{:'time_period.flex.from' => period}, {:'time_period.flex.to' => period}]
    end

    def in_between
      [{:'time_period.flex.from' => min_period}, {:'time_period.flex.to' => max_period}]
    end

    def at_least type = :min
      {:'time_period.flex.to'.gte => send("#{type}_period") }
    end

    def at_most type = :max
      {:'time_period.flex.to'.lte => send("#{type}_period") }
    end

    describe 'ASAP 2 minutes' do
      let(:period) { 2.minutes.to_i }

      let(:criteria) do
        Account.where(where_hash).or(exactly)
      end

      # it 'should have a nice criteria' do
      #   criteria.selector['$or'].should == [{"time_period.flex.from"=>120}, {"time_period.flex.to"=>120}]
      #   criteria.selector["period.from"].should be_a Hash
      # end

      it 'should find #1, #2, #3, #4, #5' do
        criteria.to_a.map(&:name).should include '1', '2', '5', '7'
      end

      let(:time_period) { criteria.first.time_period }

      specify do
        time_period.flex.should be_a DurationRange
        time_period.flex.min.should == 2.minutes
        time_period.flex.max.should == 5.minutes
      end
    end

    describe 'ASAP 3 minutes' do
      let(:period) { 3.minutes.to_i }

      let(:criteria) do
        Account.where(where_hash).or(exactly)
      end

      it 'should find #4, #10' do
        # puts criteria.to_a.map(&:name)
        criteria.to_a.map(&:name).should include '4', '10'
      end
    end

    describe 'ASAP 4 minutes' do
      let(:period) { 4.minutes.to_i }

      let(:criteria) do
        Account.where(where_hash).or(exactly)
      end

      it 'should find #2, #3' do
        criteria.to_a.should include(@acc2, @acc3)
      end
    end

    describe 'ASAP 1-4 minutes' do
      let(:min_period) { 1.minute }
      let(:max_period) { 4.minutes }

      let(:criteria) do
        Account.where(where_hash).or(in_between)
      end

      it 'should find #2, #3' do
        # puts "ASAP 1-4 minutes"
        # puts criteria.selector
        # puts criteria.to_a.map(&:name)
        criteria.to_a.map(&:name).should_not include('8', '9')
        criteria.to_a.map(&:name).should include('2', '3')
      end
    end

    describe 'ASAP 3-5 minutes' do
      let(:min_period) { 3.minutes }
      let(:max_period) { 5.minutes }

      it 'should have a nice criteria' do
        # puts "ASAP 3-5 minutes"
        # puts criteria.selector
        criteria.selector["time_period.flex.from"] = 180
        criteria.selector["time_period.flex.to"] = 300
        criteria.selector["period.from"].should be_a Hash
      end

      let(:criteria) do
        Account.where(where_hash).or(in_between)
      end

      it 'should find #2, #3' do
        # puts criteria.to_a.map(&:name)
        criteria.to_a.map(&:name).should_not include('8', '9')
        criteria.to_a.map(&:name).should include('10')
      end
    end

    describe 'ASAP 5-7 minutes' do
      let(:min_period) { 5.minutes }
      let(:max_period) { 7.minutes }

      let(:criteria) do
        Account.where(where_hash).or(in_between)
      end

      it 'should find #2, #3' do
        # puts criteria.to_a.map(&:name)
        criteria.to_a.map(&:name).should_not include('6', '9', '10')
        criteria.to_a.map(&:name).should include('8')
      end
    end

    describe 'ASAP at least 4 minutes' do
      let(:min_period) { 4.minutes }

      let(:criteria) do
        Account.where where_hash.merge(at_least)
      end

      it 'should find #2, #3' do
        # puts criteria.selector
        # puts criteria.to_a.map(&:name)
        criteria.to_a.map(&:name).should_not include '9'
        criteria.to_a.map(&:name).should include '1', '2', '3', '8', '10'
      end
    end

    describe 'ASAP at most 3 minutes' do
      let(:max_period) { 3.minutes }

      let(:criteria) do
        Account.where where_hash.merge(at_most)
      end

      it 'should find #2, #3' do
        # puts criteria.selector
        # puts criteria.to_a.map(&:name)
        criteria.to_a.map(&:name).should_not include '8', '9', '10' 
        criteria.to_a.map(&:name).should include '4', '5', '7'
      end
    end    
  end
end