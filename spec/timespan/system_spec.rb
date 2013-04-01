require 'spec_helper'

# require 'time-lord'

# To test and make sure that none of the included gems or any core extensions of this gem fuck up the 
# normal date calculation/comparison etc functionality of Ruby and Rails ;)

describe 'Ensure system Time calculations still operate as the should!' do
  it 'should add Time + Time normally' do
    expect(1.days + 3.days).to eq 4.days
  end

  it 'should add Date + Time normally' do
    expect(Date.today + 3.days).to eq 3.days.from_now
  end
end