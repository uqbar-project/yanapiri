class Entrega
  def initialize(base_path, repo)
    @base_path = base_path
    @repo = repo
  end

  def preparar_correccion!(commit_base)
    crear_branch_base!(commit_base)
    crear_branch_entrega!
    renombrar_proyecto_wollok!
  end

  def crear_pull_request!(gh_client, orga)
    gh_client.create_pull_request("#{orga}/#{@repo}", "base", "entrega", "Corrección") rescue nil
  end

  def publicar_cambios!
    `git push --all`
  end

  private

  def proyecto_wollok
    "#{@base_path}/#{@repo}/.project"
  end

  def crear_branch_base!(commit_base)
    `git checkout #{commit_base}`
    `git checkout -b base`
  end

  def crear_branch_entrega!
    `git checkout master`
    # `git checkout `git rev-list -n 1 --first-parent --before="2019-04-24 23:59:59" master``
    `git checkout -b entrega`
    `git checkout entrega`
  end

  def renombrar_proyecto_wollok!
    xml = File.read proyecto_wollok
    File.open(proyecto_wollok, "w") {|file| file.puts xml.sub(/<name>.*<\/name>/, "<name>#{@repo}</name>") }
    commit! 'Renombrado proyecto Wollok'
  end

  def commit!(mensaje)
    `git add .`
    `git commit -m "#{mensaje}"`
  end
end
