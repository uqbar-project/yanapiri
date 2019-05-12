module GitHelpers
  def crear_archivo!(nombre)
    repo.chdir { FileUtils.touch nombre }
    repo.add
    repo.commit "Creado #{nombre}"
    repo.log.first
  end

  def crear_repo!(nombre)
    Git.init "#{git_base_path}/#{nombre}"
  end

  def git_base_path
    @git_base_path ||= Dir.mktmpdir
  end
end
