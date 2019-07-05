require_relative './spec_helper'

describe Yanapiri::Entrega do
  let(:id) { 'entrega-de-ejemplo-faloi' }
  let(:repo) { crear_repo! id }
  let(:commit_base) { nil }
  let(:fecha_limite) { nil }
  let(:fecha_entrega) { Time.now }
  let(:modo_estricto) { false }
  let(:entrega) { Yanapiri::Entrega.new repo.dir.to_s, commit_base, fecha_limite, modo_estricto }

  before do
    commit_archivo_nuevo! '1.txt', {fecha: Time.new(2018, 8, 25)}
    commit_archivo_nuevo! '2.txt', {fecha: fecha_entrega}
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
      it { expect(entrega.hay_cambios?).to be_falsey }
    end

    context 'con base elegido por índice' do
      context 'con cambios' do
        let(:commit_base) { 'index:1' }
        it { expect(entrega.hay_cambios?).to be_truthy }
      end

      context 'sin cambios' do
        let(:commit_base) { 'index:2' }
        it { expect(entrega.hay_cambios?).to be_falsey }
      end

      context 'fuera de rango' do
        let(:commit_base) { 'index:3' }
        it { expect(entrega.hay_cambios?).to be_falsey }
      end
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

  describe '#mensaje_pull_request' do
    it 'cuando está en término' do
      expect(entrega.mensaje_pull_request).to be_empty
    end

    context 'cuando está fuera de término' do
      let(:fecha_limite) { Time.new(2018, 8, 30, 23, 59, 59) }
      let(:fecha_entrega) { Time.new(2018, 8, 31, 1, 55, 40) }

      it 'en modo relajado' do
        expect(entrega.mensaje_pull_request).to eq "**Ojo:** tu último commit fue el 31/08/2018 a las 01:55, pero la fecha límite era el 30/08/2018 a las 23:59.\n\n¡Tenés que respetar la fecha de entrega establecida! :point_up:"
      end

      context 'en modo estricto' do
        let(:modo_estricto) { true }
        before { commit_archivo_nuevo! '3.txt', {fecha: fecha_entrega + 1.minute } }
        it { expect(entrega.mensaje_pull_request).to eq "**Ojo:** tu último commit fue el 31/08/2018 a las 01:56, pero la fecha límite era el 30/08/2018 a las 23:59.\n\n¡Tenés que respetar la fecha de entrega establecida! :point_up:\n\nNo se tuvieron en cuenta los siguientes commits:\n\n* Creado 3.txt (#{commits.last.sha})\n* Creado 2.txt (#{commits[1].sha})" }
      end
    end
  end

  describe '#crear_branch_entrega!' do
    before { entrega.crear_branch_entrega! }

    it 'cuando está en término' do
      expect(repo.branches['entrega']).to have_last_commit commits.last
    end

    context 'cuando está fuera de término' do
      let(:fecha_limite) { Time.new(2018, 8, 30, 23, 59, 59) }
      let(:fecha_entrega) { Time.new(2018, 8, 31, 1, 55, 40) }

      it 'en modo relajado' do
        expect(repo.branches['entrega']).to have_last_commit commits.last
      end

      context 'en modo estricto' do
        let(:modo_estricto) { true }
        it { expect(repo.branches['entrega']).to have_last_commit commits.first }
      end
    end
  end

  describe '#to_s' do
    let(:fecha_entrega) { Time.new(2018, 8, 31, 1, 55, 40) }

    it 'cuando está en termino' do
      expect(entrega.to_s).to eq "entrega de @faloi, modificada por última vez el 31/08/2018 a las 01:55"
    end

    context 'cuando no hay cambios' do
      let(:commit_base) { commits.last.sha }
      it { expect(entrega.to_s).to eq "entrega de @faloi, sin cambios" }
    end

    context 'cuando está fuera de término' do
      let(:fecha_limite) { Time.new(2018, 8, 30, 23, 59, 59) }
      it { expect(entrega.to_s).to eq "entrega de @faloi, modificada por última vez el 31/08/2018 a las 01:55 (fuera de término)" }
    end
  end
end
