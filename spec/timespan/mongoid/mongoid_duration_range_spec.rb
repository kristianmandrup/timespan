require 'timespan/mongoid/spec_helper'

Mongoid::Timespanned.log = true
load_models!

describe TimeSpan do
  subject { account }

  def tomorrow
    Date.today + 1.day
  end

  def format_date date
    DateTime.parse(date.to_s).strftime('%d %b %Y')
  end  

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  context 'Mongoid' do
    describe 'DurationRange' do

      let(:account) do 
        Account.create_it! 2.days, (0..3).minutes
      end

          # subject.time_period.dates_end = tomorrow + 3.days
          # subject.end_date = tomorrow + 3.days

      context 'set start of period to tomorrow' do
        before do
          subject.period_start = tomorrow

          puts "period: #{subject.period}"
        end

        it 'should set start_date to tomorrow' do
          format_date(subject.period.start_date).should == format_date(tomorrow)
        end
      end

      context 'set end of period to tomorrow + 5 days' do
        before do
          subject.period_end = tomorrow + 5.days
        end

        it 'should set start_date to tomorrow' do
          format_date(subject.period.end_date).should == format_date(tomorrow + 5.days)
        end
      end

      context 'set flex to 1-3 days' do
        before do
          subject.time_period.flex = (1..3).days
        end

        it 'should set flex duration range to a DurationRange' do
          expect(subject.time_period.flex).to be_a ::DurationRange
        end

        it 'should set flex duration range to days' do
          expect(subject.time_period.flex.unit).to eq :days
        end

        it 'should set flex duration to min 1 days' do
          expect(subject.time_period.flex.min).to eq 1.days
        end

        it 'should set flex duration to max 3 days' do
          expect(subject.time_period.flex.max).to eq 3.days
        end
      end
    end

    describe 'LongDurationRange' do
      let(:account) do 
        Account.create_it! 2.days
      end

      before do
        subject.time_period.flex = (2..3).weeks!
      end

      it 'should set flex duration range to a LongDurationRange' do
        expect(subject.time_period.flex).to be_a ::LongDurationRange
      end

      it 'should set flex duration range to 2-3 weeks' do
        expect(subject.time_period.flex.unit).to eq :weeks
      end

      it 'should set flex duration to min 2 week' do
        expect(subject.time_period.flex.min).to eq 2.weeks
      end

      it 'should set flex duration to max 3 weeks' do
        expect(subject.time_period.flex.max).to eq 3.weeks
      end
    end

    describe 'ShortDurationRange' do
      context 'preset to 2-4 days' do
        let(:account) do 
          Account.create_it! 2.days, (2..4).days!
        end

        specify do
          ((2..5).days! == (2..4).days!).should be_false
        end

        specify do
          ((2..5).days! > (2..4).days!).should be_true
        end

        specify do
          ((1..3).days! < (2..4).days!).should be_true
        end

        specify do
          subject.time_period.flex.should be_a ::LongDurationRange
        end

        it 'should be set to 2-4 days time' do
          expect(subject.time_period.flex.time).to eq (2..4).days!.time
        end

        it 'should be set to 2-4 days' do
          expect(subject.time_period.flex.to_s).to eq (2..4).days!.to_s
        end

        it 'should be set to min 2 days' do
          expect(subject.time_period.flex.min).to eq 2.days
        end

        it 'should be set to max 4 days' do
          expect(subject.time_period.flex.max).to eq 4.days
        end

        context 'set to 1-4 minutes' do
          before do
            subject.time_period.flex = (2..3).minutes!
          end

          it 'should set flex duration range to a LongDurationRange' do
            expect(subject.time_period.flex).to be_a ::ShortDurationRange
          end

          it 'should set flex duration range to 2-3 minutes' do
            expect(subject.time_period.flex.unit).to eq :minutes
            expect(subject.time_period.flex.min).to eq 2.minutes
            expect(subject.time_period.flex.max).to eq 3.minutes
          end
        end
      end
    end
  end
end