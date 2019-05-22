require_relative './spec_helper'

describe Yanapiri::Bot do
  let(:organization) { 'obj1-unahur-2019' }
  let(:github_client) { double 'github_client' }
  let(:bot) { Yanapiri::Bot.new organization, github_client }
  let(:repo) { crear_repo! 'camion-transporte-warmichina' }
  let!(:commit_base) { commit_archivo_nuevo! '1.txt' }
  let(:entrega) { Yanapiri::Entrega.new repo.dir.to_s, commit_base }

  describe '#commit!' do
    before do
      crear_archivo! '2.txt'
      bot.commit! repo, 'Un, dos, tres, probando'
    end

    it { expect(commits.last).to have_author 'Yanapiri Bot <bot@yanapiri.org>' }
  end

  describe '#preparar_correccion!' do
    it 'cuando no hay cambios' do
      expect(github_client).to receive(:create_issue)
      bot.preparar_correccion! entrega
    end

    context 'cuando hay cambios' do
      let(:transformaciones) { [Yanapiri::TransformacionWollok] }

      before do
        crear_archivos_entrega!
        expect(github_client).to receive(:create_pull_request)
        bot.preparar_correccion! entrega, transformaciones
      end

      context 'sin proyecto Wollok' do
        def crear_archivos_entrega!
          commit_archivo_nuevo! 'solution.txt'
        end

        it { expect(repo).to have_branch 'base' }
        it { expect(repo).to have_remote_branch 'base' }
        it { expect(repo.branches['base']).to have_last_commit commit_base }

        it { expect(repo).to have_branch 'entrega' }
        it { expect(repo).to have_remote_branch 'entrega' }
        it { expect(repo.branches['entrega']).to have_last_commit commits.last }
      end

      context 'con proyecto Wollok' do
        def crear_archivos_entrega!
          commit_archivo_nuevo! '.project', {source: 'wollokProject'}
        end

        it 'con transformación' do
          expect(repo.branches['entrega']).to have_last_commit_message 'Renombrado proyecto Wollok'
          expect(repo.show 'entrega', '.project').to include '<name>camion-transporte-warmichina</name>'
        end

        context 'sin transformación' do
          let(:transformaciones) { [] }
          it { expect(repo.show 'entrega', '.project').not_to include '<name>camion-transporte-warmichina</name>' }
        end
      end

      context 'con proyecto Wollok ya corregido' do
        def crear_archivos_entrega!
          commit_archivo_nuevo! '.project', {source: 'wollokProjectCorregido'}
        end

        it { expect(repo.show 'entrega', '.project').to include '<name>camion-transporte-warmichina</name>' }
      end
    end
  end

  describe '#aplanar_commits!' do
    before do
      commit_archivo_nuevo! 'README.md'
      commit_archivo_nuevo! 'template.wlk'
      commit_archivo_nuevo! 'template.wtest'

      repo.branch('prueba').checkout
      repo.push 'origin', 'master', {mirror: true}

      bot.aplanar_commits! repo
    end

    it { expect(repo.log.size).to eq 1 }
    it { expect(repo.branches.remote.map &:name).to eq ['master', 'prueba'] }
    it { expect(repo.branches.local.map &:name).to eq ['master'] }
    it { expect(repo).to have_branch 'master' }
    it { expect(repo.log.first).to have_author bot.git_author }
  end
end
