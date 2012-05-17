require 'spec_helper'
require 'i18n'

I18n.load_path << File.join(File.dirname(__FILE__), 'locales', 'duration_da.yml')

describe Timespan::Span do
  subject { timespan }

  let(:from) { Chronic.parse("1 day ago") }
  let(:to)   { Time.now }

  before do
  	I18n.locale = :da
  end

  describe 'print in danish - multiple modes' do
    let(:timespan) { Timespan.new :from => from, :to => to }    

    let(:today)     { Date.today.strftime('%d %b %Y') }
    let(:yesterday) { 1.day.ago.strftime('%d %b %Y') }

    its(:to_s) { should == "fra #{yesterday} til #{today} der varer ialt 1 dag" }

    specify { subject.to_s(:dates).should == "fra #{yesterday} til #{today}" }
    specify { subject.to_s(:duration).should == '1 dag' }
  end
end
