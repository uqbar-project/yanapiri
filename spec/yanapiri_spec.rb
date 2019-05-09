require_relative './spec_helper'

describe Yanapiri do
  context 'tiene una versión' do
    it { expect(Yanapiri::VERSION).to be }
  end
end
