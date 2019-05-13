module GitHelpers
  def commit_archivo_nuevo!(nombre, fecha = DateTime.now)
    with_commit_time(fecha) do
      crear_archivo!(nombre)
      repo.add
      repo.commit "Creado #{nombre}"
      repo.log.first
    end
  end

  def crear_archivo!(nombre)
    repo.chdir {FileUtils.touch nombre}
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
    repo.log.to_a.reverse
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
