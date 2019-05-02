class Bot
  attr_reader :organization
  
  def initialize(organization, gh_token)
    @organization = organization
    @gh_client = Octokit::Client.new(access_token: gh_token)
  end

  def clonar_entrega!(nombre)
    result = @gh_client.search_repositories "org:#{@organization} #{nombre} in:name", {per_page: 200}
    puts "Encontrados #{result.total_count} repositorios."
    FileUtils.mkdir_p nombre
    Dir.chdir(nombre) do
      result.items.each do |repo|
        puts "Clonando #{repo.name}..."
        Git.clone repo.ssh_url, repo.name
      end
    end
  end

  def preparar_correccion!(entrega, commit_base)
    entrega.crear_branch! 'base', commit_base
    entrega.crear_branch! 'entrega', 'master'
    renombrar_proyecto_wollok! entrega
    publicar_cambios! entrega
    crear_pull_request! entrega
  end

  private

  def crear_pull_request!(entrega)
    @gh_client.create_pull_request("#{@organization}/#{entrega.id}", "base", "entrega", "Corrección", entrega.mensaje_pull_request) rescue nil
  end

  def renombrar_proyecto_wollok!(entrega)
    entrega.repo.chdir do
      xml = File.read proyecto_wollok
      File.open(proyecto_wollok, "w") {|file| file.puts xml.sub(/<name>.*<\/name>/, "<name>#{entrega.id}</name>") }
    end

    entrega.repo.commit_all 'Renombrado proyecto Wollok'
  end

  def publicar_cambios!(entrega)
    entrega.repo.push 'origin', '--all'
  end

  def proyecto_wollok
    '.project'
  end
end
