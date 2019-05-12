require_relative './spec_helper'

describe Yanapiri::Entrega do
  let(:id) { 'entrega-de-ejemplo-faloi' }
  let(:repo) { crear_repo! id }
  let(:commit_base) { nil }
  let(:fecha_limite) { nil }
  let(:entrega) { Yanapiri::Entrega.new repo.dir.to_s, commit_base, fecha_limite }

  before do
    commit_archivo_nuevo! '1.txt'
    commit_archivo_nuevo! '2.txt'
  end

  describe '#fecha' do
    it { expect(entrega.fecha).to eq commits.last.author_date }
  end

  describe '#hay_cambios?' do
    context 'con base anterior' do
      let(:commit_base) { commits.first.sha }
      it { expect(entrega.hay_cambios?).to be_truthy }
    end

    context 'con base igual a último commit' do
      let(:commit_base) { commits.last.sha }
      it { expect(entrega.hay_cambios?).to be_falsy }
    end
  end

  describe '#autor' do
    it { expect(entrega.autor).to eq 'faloi' }
  end

  describe '#fuera_de_termino?' do
    context 'sin fecha límite' do
      it { expect(entrega.fuera_de_termino?).to be_falsey }
    end

    context 'con fecha anterior' do
      let(:fecha_limite) { Time.now - 1.day }
      it { expect(entrega.fuera_de_termino?).to be_truthy }
    end

    context 'con fecha posterior' do
      let(:fecha_limite) { Time.now + 5.days }
      it { expect(entrega.fuera_de_termino?).to be_falsey }
    end
  end
end
