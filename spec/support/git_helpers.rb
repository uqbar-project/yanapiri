module GitHelpers
  extend RSpec::Matchers::DSL

  def commit_archivo_nuevo!(nombre, options = {})
    config = {fecha: DateTime.now}.merge options
    with_commit_time(config[:fecha]) do
      if options[:source] then copiar_archivo!(options[:source], nombre) else crear_archivo!(nombre) end
      repo.add
      repo.commit "Creado #{nombre}"
      repo.log.first
    end
  end

  def crear_archivo!(nombre)
    repo.chdir {FileUtils.touch nombre}
  end

  def copiar_archivo!(origen, nombre)
    FileUtils.cp "spec/data/#{origen}",  "#{repo.dir.path}/#{nombre}"
  end

  def crear_repo!(nombre)
    remote_path = Dir.mktmpdir
    Git.init remote_path, {bare: true, repository: remote_path}
    Git.clone remote_path, nombre, {path: "#{git_base_path}/#{nombre}"}
  end

  def git_base_path
    @git_base_path ||= Dir.mktmpdir
  end

  def commits
    repo.checkout 'master'
    repo.log.to_a.reverse
  end

  matcher :have_last_commit do |expected|
    match {|branch| expect(branch.gcommit).to eq_commit expected}
  end

  matcher :have_last_commit_message do |expected|
    match {|branch| expect(branch.gcommit.message).to eq expected}
  end

  matcher :include_commit_with_message do |expected|
    match do |branch|
      branch.checkout
      expect(branch.instance_variable_get(:@base).log.any? { |it| it.message == expected }).to be_truthy
    end
  end

  matcher :have_branch do |expected|
    match {|repo| expect(repo.branches.map &:name).to include expected}
  end

  matcher :have_remote_branch do |expected|
    match {|repo| expect(repo.branches.remote.map &:name).to include expected}
  end

  matcher :have_author do |expected|
    match {|commit| expect("#{commit.author.name} <#{commit.author.email}>").to eq expected}
  end

  matcher :eq_commit do |expected|
    match {|actual| expect(expected.sha).to eq actual.sha}
  end

  private

  def with_commit_time(time)
    original_env = ENV.to_hash
    timestamp = time.utc.strftime('%c %z')

    ENV['GIT_AUTHOR_DATE']     = timestamp
    ENV['GIT_COMMITTER_DATE']  = timestamp

    yield
  ensure
    ENV.replace(original_env.to_hash)
  end
end
