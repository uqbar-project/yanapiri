require_relative './spec_helper'

describe Yanapiri do
  it 'tiene una versión' do
    expect(Yanapiri::VERSION).not_to be nil
  end
end
