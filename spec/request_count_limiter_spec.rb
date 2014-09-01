require 'spec_helper'

describe Coppertone::RequestCountLimiter do
  let(:counter_description) { SecureRandom.hex(10) }

  it 'should handle the basic case correctly' do
    limiter = Coppertone::RequestCountLimiter.new(5, counter_description)
    expect(limiter).to be_limited
    expect(limiter.increment!).to eq(1)
    expect(limiter.increment!).to eq(2)
    expect(limiter.increment!(2)).to eq(4)
    expect(limiter.increment!).to eq(5)
    expect(limiter).not_to be_exceeded
    expect { limiter.increment! }
      .to raise_error Coppertone::LimitExceededError,
                      "Maximum #{counter_description} limit of 5 exceeded."
    expect(limiter).to be_exceeded
  end

  it 'should not raise an error if no limit is specified' do
    limiter = Coppertone::RequestCountLimiter.new
    expect(limiter).not_to be_limited
    expect(limiter.increment!).to eq(1)
    expect(limiter.increment!(1000)).to eq(1001)
    expect(limiter.count).to eq(1001)
    expect(limiter).not_to be_exceeded
  end
end
