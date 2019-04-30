class Entrega
  attr_reader :fecha_limite

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

  def crear_pull_request!(bot)
    bot.crear_pull_request!(@id, mensaje_pull_request)
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

  def mensaje_pull_request
    if fuera_de_termino?
      "**Ojo:** tu último commit fue el #{formato_humano fecha}, pero la fecha límite era el #{formato_humano fecha_limite}.\n\n¡Tenés que respetar la fecha de entrega establecida! :point_up:"
    else
      ''
    end
  end

  def mensaje_ultimo_commit
    "#{autor} hizo su último commit el #{fecha}." + (fuera_de_termino? ? " Fuera de término." : "")
  end

  private

  def formato_humano(fecha)
    fecha.strftime("%d/%m/%Y a las %H:%M")
  end

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
