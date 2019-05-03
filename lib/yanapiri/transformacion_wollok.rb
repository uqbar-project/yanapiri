module TransformacionWollok
  def self.aplica?(entrega)
    entrega.contiene_archivo? proyecto_wollok
  end

  def self.transformar!(entrega, bot)
    entrega.repo.chdir do
      xml = File.read proyecto_wollok
      File.open(proyecto_wollok, "w") {|file| file.puts xml.sub(/<name>.*<\/name>/, "<name>#{entrega.id}</name>") }
    end

    bot.commit! entrega.repo, 'Renombrado proyecto Wollok'
  end

  def self.proyecto_wollok
    '.project'
  end
end