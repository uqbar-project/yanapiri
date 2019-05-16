require_relative './spec_helper'

describe Yanapiri::MultiSourceConfig do
  let(:first)   { {a: 1} }
  let(:others)  { [] }
  let(:config)  { Yanapiri::MultiSourceConfig.new first, *others }

  describe 'read' do
    context 'con una sola configuración' do
      it { expect(config.a).to eq 1 }
    end

    context 'con varias configuraciones' do
      let(:others)  { [{a: 2, b: 'hola'}, {a: 3, c: true }] }

      it { expect(config.a).to eq 3 }
      it { expect(config.b).to eq 'hola' }
      it { expect(config.c).to eq true }
    end

    context 'con valores booleanos' do
      let(:others)  { [{b: false, c: false, d: true, e: true}, {c: true, e: false }] }

      it { expect(config.b).to eq false }
      it { expect(config.c).to eq true }
      it { expect(config.d).to eq true }
      it { expect(config.e).to eq false }
    end
  end
end
