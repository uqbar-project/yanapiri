module Yanapiri
  class Entrega
    attr_reader :id, :fecha_limite, :repo, :commit_base
    delegate :mensaje_pull_request, :commit_entrega, to: :@modo

    def initialize(repo_path, commit_base = nil, fecha_limite = nil, modo_estricto = false)
      @id = File.basename repo_path
      @fecha_limite = fecha_limite || Time.now + 1.second
      @commit_base = commit_base || '--max-parents=0 HEAD'
      @modo = (modo_estricto ? ModoEstricto : ModoRelajado).new self
      @repo = Git.open repo_path
    end

    def fuera_de_termino?
      commits_fuera_de_termino.any?
    end

    def autor
      @id.split('-').first
    end

    def fecha
      @repo.checkout 'master'
      @repo.log.first.author_date
    end

    def contiene_archivo?(nombre)
      @repo.chdir { File.exist? nombre }
    end

    def commits_fuera_de_termino
      @repo.checkout 'master'
      @repo.log.since(@fecha_limite.iso8601)
    end

    def hay_cambios?
      @repo.log.between(@commit_base, 'master').any?
    end

    def crear_branch_entrega!
      crear_branch! 'entrega', commit_entrega
    end

    def crear_branch_base!
      crear_branch! 'base', commit_base
    end

    def to_s
      string = "entrega de @#{autor}, "
      string << if hay_cambios? then "modificada por última vez #{formato_humano fecha}" else "sin cambios" end
      string << ' (fuera de término)' if fuera_de_termino?
      string
    end

    def formato_humano(fecha)
      I18n.l(fecha, format: :human)
    end

    private

    def crear_branch!(nombre, head)
      @repo.checkout head
      @repo.branch(nombre).checkout
    end

    class ModoCorreccion
      delegate_missing_to :@entrega

      def initialize(entrega)
        @entrega = entrega
      end

      def mensaje_pull_request
        if fuera_de_termino? then mensaje_fuera_de_termino else '' end
      end

      def mensaje_fuera_de_termino
        "**Ojo:** tu último commit fue #{formato_humano fecha}, pero la fecha límite era #{formato_humano fecha_limite}.\n\n¡Tenés que respetar la fecha de entrega establecida! :point_up:"
      end
    end

    class ModoEstricto < ModoCorreccion
      def mensaje_fuera_de_termino
        super + "\n\nNo se tuvieron en cuenta los siguientes commits:\n\n#{commits_desestimados}"
      end

      def commit_entrega
        repo.checkout 'master'
        repo.log.until(fecha_limite.iso8601).first.sha
      end

      private

      def commits_desestimados
        commits_fuera_de_termino.map {|c| "* #{c.message} (#{c.sha})"}.join("\n")
      end
    end

    class ModoRelajado < ModoCorreccion
      def commit_entrega
        'master'
      end
    end
  end
end
