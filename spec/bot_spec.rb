require_relative './spec_helper'

describe Yanapiri::Bot do
  let(:organization) { 'obj1-unahur-2019' }
  let(:github_client) { double }
  let(:bot) { Yanapiri::Bot.new organization, github_client }
  let(:repo) { crear_repo! 'ejemplo' }
  let(:entrega) { Yanapiri::Entrega.new repo.dir.to_s, commits.first }

  before do
    commit_archivo_nuevo! '1.txt'
  end

  describe '#commit!' do
    before do
      crear_archivo! '2.txt'
      bot.commit! repo, 'Un, dos, tres, probando'
    end

    let(:git_author) { commits.last.author }
    it { expect(git_author.name).to eq 'Yanapiri Bot' }
    it { expect(git_author.email).to eq 'bot@yanapiri.org' }
  end

  describe '#preparar_correccion!' do
    it 'cuando no hay cambios' do
      expect(github_client).to receive(:create_issue)
      bot.preparar_correccion! entrega
    end

    context 'cuando hay cambios' do
      before do
        commit_archivo_nuevo! 'solution.wlk'
        expect(github_client).to receive(:create_pull_request)
        bot.preparar_correccion! entrega
      end

      let(:branches) { repo.branches.map &:name }
      it { expect(branches).to include('base') }
      it { expect(branches).to include('entrega') }
    end
  end
end
