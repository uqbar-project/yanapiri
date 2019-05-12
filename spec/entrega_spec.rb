require_relative './spec_helper'

describe Yanapiri::Entrega do
  let(:base_path) { Dir.mktmpdir }
  let(:repo) { Git.init "#{base_path}/#{id}" }
  let(:id) { 'entrega-de-ejemplo-faloi' }
  let(:commit_base) { nil }
  let(:fecha_limite) { nil }
  let(:entrega) { Yanapiri::Entrega.new base_path, id, commit_base, fecha_limite }

  def crear_archivo(nombre)
    repo.chdir { FileUtils.touch nombre }
    repo.add
    repo.commit "Creado #{nombre}"
    repo.log.first
  end

  let!(:commits) {%w(1.txt 2.txt).map(&method(:crear_archivo))}

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
