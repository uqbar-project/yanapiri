require_relative './spec_helper'

describe Yanapiri::Entrega do
  let(:repo) { Git.init "#{base_path}/#{id}" }
  let(:base_path) { Dir.mktmpdir }
  let(:id) { 'spa-faloi' }
  let(:entrega) { Yanapiri::Entrega.new base_path, id}

  def crear_archivo(nombre)
    repo.chdir { FileUtils.touch nombre }
    repo.add
    repo.commit "Creado #{nombre}"
    repo.gcommit 'HEAD'
  end

  context 'la fecha sale del último commit' do
    let!(:ultimo_commit) do
      crear_archivo '1.txt'
      crear_archivo '2.txt'
    end

    it { expect(entrega.fecha).to eq ultimo_commit.author_date }
  end
end
