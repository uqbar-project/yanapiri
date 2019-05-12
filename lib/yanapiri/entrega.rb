module Yanapiri
  class Entrega
    attr_reader :id, :fecha_limite, :repo, :commit_base

    def initialize(repo_path, commit_base = nil, fecha_limite = nil)
      @id = File.basename repo_path
      @fecha_limite = fecha_limite || Time.now + 1.second
      @commit_base = commit_base || '--max-parents=0 HEAD'
      @repo = Git.open repo_path
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

    def crear_branch!(nombre, head)
      @repo.checkout head
      @repo.branch(nombre).checkout
    end

    def contiene_archivo?(nombre)
      @repo.chdir { File.exist? nombre }
    end

    def hay_cambios?
      @repo.log.between(@commit_base, 'master').any?
    end

    private

    def formato_humano(fecha)
      fecha.strftime("%d/%m/%Y a las %H:%M")
    end
  end
end