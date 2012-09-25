require 'timespan/mongoid/spec_helper'

describe TimeSpan do
  subject { account }

  context '5 Accounts with periods serialized' do
    before do
      Account.delete_all

      @acc1 = Account.create duration: Timespan.asap(at_least: 2.months)
      # @acc2 = Account.create duration: Timespan.asap(between: (2..4).months)
      # @acc3 = Account.create duration: Timespan.asap(at_most: 4.months)
      # @acc4 = Account.create duration: Timespan.asap(at_most: 3.months)
      # @acc5 = Account.create duration: Timespan.asap(at_most: 2.months)

      # # start_date on period, at_most on duration
      # @acc6 = Account.create_period start_date: 1.month.from_now, at_most: 2.months
      # # start_date on period, at_least on duration
      # @acc7 = Account.create_period start_date: 1.month.from_now, at_least: 3.months
    end

    describe 'ASAP 2 months' do
      let(:period) { 3.months }

      it 'should find #1, #2, #3, #4, #5' do
        Account.or('duration.from'.eq => period, 'duration.to'.eq => period).where('period.from'.gte => Time.now)
      end
    end

    # describe 'ASAP 3 months' do
    #   let(:period) { 3.months }

    #   it 'should find #1, #2, #3, #4' do
    #     Account.or('duration.from'.eq => period, 'duration.to'.eq => period).where('period.from'.gte => Time.now)
    #   end
    # end

    # describe 'ASAP 4 months' do
    #   let(:period) { 4.months }

    #   it 'should find #1, #2, #3' do
    #     Account.or('duration.from'.eq => period, 'duration.to'.eq => period).where('period.from'.gte => Time.now)
    #   end
    # end

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