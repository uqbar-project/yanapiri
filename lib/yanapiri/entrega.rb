class Entrega
  def initialize(base_path, id, fecha_limite = Time.now)
    @base_path = base_path
    @id = id
    @fecha_limite = fecha_limite
    @repo = Git.open "#{@base_path}/#{@id}"
  end

  def preparar_correccion!(commit_base)
    crear_branch_base!(commit_base)
    crear_branch_entrega!
    renombrar_proyecto_wollok!
  end

  def crear_pull_request!(gh_client, orga)
    gh_client.create_pull_request("#{orga}/#{@id}", "base", "entrega", "Corrección") rescue nil
  end

  def publicar_cambios!
    @repo.push 'origin', '--all'
  end

  def fuera_de_termino?
    @repo.checkout 'master'
    @repo.log.since(@fecha_limite.iso8601).any?
  end

  def autor
    @id.split('-').last
  end

  def fecha
    @repo.checkout 'master'
    @repo.log.first.author_date
  end

  private

  def proyecto_wollok
    '.project'
  end

  def crear_branch_base!(commit_base)
    @repo.checkout commit_base
    @repo.branch('base').checkout
  end

  def crear_branch_entrega!
    @repo.checkout 'master'
    @repo.branch('entrega').checkout
  end

  def renombrar_proyecto_wollok!
    @repo.chdir do
      xml = File.read proyecto_wollok
      File.open(proyecto_wollok, "w") {|file| file.puts xml.sub(/<name>.*<\/name>/, "<name>#{@id}</name>") }
    end

    @repo.commit_all 'Renombrado proyecto Wollok'
  end
end
