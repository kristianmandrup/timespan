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

    its(:to_s) { should == 'fra 03 May 2012 til 04 May 2012 der varer ialt 1 dag' }

    specify { subject.to_s(:dates).should == 'fra 03 May 2012 til 04 May 2012' }
    specify { subject.to_s(:duration).should == '1 dag' }
  end
end
