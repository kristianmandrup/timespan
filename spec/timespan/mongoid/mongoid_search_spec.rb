require 'timespan/mongoid/spec_helper'
load_models!

describe TimeSpan do
  subject { account }

  context '3 Accounts with periods serialized' do
    before do
      Account.delete_all
      @acc1 = Account.create :period => Timespan.new(:start_date => 2.days.ago)
      @acc2 = Account.create :period => Timespan.new(:start_date => 5.days.ago, :end_date => 2.days.ago)
      @acc3 = Account.create :period => Timespan.new(:start_date => 10.days.ago)
    end

    describe 'find accounts within specific period' do
      it 'should find a single period less than 6 days old' do
        Account.where(:'period.from'.lt => 6.days.ago.to_i).first.should == @acc3
      end

      it 'should find a single period later than 3 days old' do
        Account.where(:'period.from'.gt => 3.days.ago.to_i).first.should == @acc1
      end

      describe 'find a single period that is within period from 6 days ago to tomorrow' do
        it 'should use Account.where' do
          Account.where(:'period.from'.gt => 6.days.ago.to_i, :'period.to'.lte => 1.day.ago.to_i).first.should == @acc2
        end

        it 'should use Account class helper #between' do
          Account.between(6.days.ago, 1.day.ago).first.should == @acc2
        end

        it 'should use Account class generated helper #period_between' do
          Account.period_between(6.days.ago, 1.day.ago).first.should == @acc2
        end
      end
    end
  end
end