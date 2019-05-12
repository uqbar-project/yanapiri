require_relative './spec_helper'

describe Yanapiri::Bot do
  let(:organization) { 'obj1-unahur-2019' }
  let(:bot) { Yanapiri::Bot.new organization, '1234' }

  describe '#commit!' do
    let(:repo) { crear_repo! 'ejemplo' }

    before do
      crear_archivo! '1.txt'
      bot.commit! repo, 'Un, dos, tres, probando'
    end

    let(:git_author) { commits.last.author }
    it { expect(git_author.name).to eq 'Yanapiri Bot' }
    it { expect(git_author.email).to eq 'bot@yanapiri.org' }
  end
end
