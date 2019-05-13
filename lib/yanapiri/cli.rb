module Yanapiri
  class CLI < Thor
    include Thor::Actions
    include ActionView::Helpers::DateHelper

    class_option :orga, {aliases: :o}
    class_option :github_token

    def initialize(args = [], local_options = {}, config = {})
      super(args, local_options, config)
      @bot = crear_bot options
    end

    def self.exit_on_failure?
      true
    end

    map %w(--version -v) => :version
    desc "--version, -v", "Muestra la versión actual de Yanapiri"
    def version
      say "yanapiri version #{VERSION}"
    end

    desc 'setup', 'Configura a Yanapiri para el primer uso'
    def setup
      say '¡Kamisaraki! Yo soy Yanapiri, tu ayudante, y necesito algunos datos antes de empezar:', :bold

      config = OpenStruct.new
      config.github_token = ask 'Token de GitHub (lo necesito para armar los pull requests):'
      config.orga = ask 'Organización por defecto:'

      begin
        bot = crear_bot config
        success "Los pull requests serán creados por @#{bot.github_user.login}, asegurate de que tenga los permisos necesarios en las organizaciones que uses."
        dump_global_config! config
      rescue Octokit::Unauthorized
        raise 'El access token de GitHub no es correcto, revisalo por favor.'
      end
    end

    desc 'init', 'Inicializa una carpeta para contener entregas'
    def init
      config = OpenStruct.new
      config.orga = ask 'Nombre de la organización:', default: File.basename(Dir.pwd)
      success "De ahora en más, trabajaré con la organización #{config.orga} siempre que estés dentro de esta carpeta."
      dump_local_config! config
    end

    desc 'whoami', 'Muestra organización y usuario con el que se está trabajando'
    def whoami
      say "Estoy trabajando en la organización #{@bot.organization}, commiteando con el usuario #{@bot.git_author}."
    end

    desc 'clonar [ENTREGA]', 'Clona todos los repositorios de la entrega dentro de una subcarpeta'
    def clonar(nombre)
      @bot.clonar_entrega!(nombre)
    end

    option :repo_base, {required: true, aliases: :b}
    desc 'actualizar [ENTREGA]', 'Actualiza cada repositorio con el contenido que haya en el repositorio base'
    def actualizar(nombre)
      path_repo_base = "#{nombre}-base"
      `git clone git@github.com:#{options.repo_base}.git #{path_repo_base}`

      foreach_repo(nombre) do
        `git remote rm base`
        `git remote add base ../../#{path_repo_base}`
        `git pull base master`
        `git push origin master`
      end

      `rm -rf #{path_repo_base}`
    end

    option :repo_base, {required: true, aliases: :b}
    desc 'preparar [ENTREGA]', 'Crea el repositorio que va a servir de base para la entrega, con un solo commit en la rama master'
    def preparar(nombre)
      @bot.preparar_entrega! nombre, options.repo_base
    end

    desc 'corregir [ENTREGA]', 'Prepara la entrega para la corrección, creando los archivos y el pull request'
    option :commit_base, {required: true, aliases: :b}
    option :fecha_limite, {default: Time.now.to_s, aliases: :l}
    option :renombrar_proyecto_wollok, {type: :boolean, default: true}
    def corregir(nombre)
      foreach_entrega(nombre) do |entrega|
        @bot.preparar_correccion! entrega, options.renombrar_proyecto_wollok ? [TransformacionWollok] : []
      end
    end

    desc 'ultimo_commit [ENTREGA]', 'Muestra la fecha del último commit de cada repositorio e indica si se pasó de la fecha límite'
    option :fecha_limite, {default: Time.now.to_s, aliases: :l}
    option :commit_base, {aliases: :b}
    option :solo_excedidos, {type: :boolean}
    def ultimo_commit(nombre)
      print_table entregas(nombre)
          .select {|e| not options.solo_excedidos or e.fuera_de_termino?}
          .sort_by(&:fecha)
          .reverse!
          .map(&method(:fila_ultimo_commit))
    end

    no_commands do
      def crear_bot(config)
        Bot.new config.orga, Octokit::Client.new(access_token: config.github_token)
      end

      def fila_ultimo_commit(entrega)
        fecha = if entrega.hay_cambios?
                  "hace #{time_ago_in_words entrega.fecha} (#{entrega.fecha.strftime "%d/%m/%Y %H:%M"})"
                else
                  '(no hay cambios)'
                end

        fila = [entrega.autor, fecha, if entrega.fuera_de_termino? then '---> Fuera de término' else '' end]
        color = if entrega.fuera_de_termino? then :red else :white end
        fila.map {|s| set_color s, color }
      end

      def foreach_repo(dir_base)
        Dir.chdir(dir_base) do
          working_dir = Dir.pwd
          repos = Dir.glob('*').select {|f| File.directory? f}.sort

          for repo in repos
            Dir.chdir "#{working_dir}/#{repo}" do
              yield repo, working_dir
            end
          end
        end
      end

      def foreach_entrega(nombre)
        foreach_repo(nombre) do |repo, base_path|
          yield Entrega.new "#{base_path}/#{repo}", options.commit_base, Time.parse(options.fecha_limite)
        end
      end

      def entregas(nombre)
        resultado = []
        foreach_entrega(nombre) { |e| resultado << e }
        resultado
      end

      def global_config_file
        File.expand_path "~/#{config_file_name}"
      end

      def local_config_file
        File.expand_path config_file_name
      end

      def config_file_name
        '.yanapiri'
      end

      def dump_global_config!(config)
        dump_config! global_config_file, config
      end

      def dump_local_config!(config)
        dump_config! local_config_file, config
      end

      def dump_config!(destination, config)
        File.write destination, config.to_h.stringify_keys.to_yaml
      end

      def load_config(source)
        if File.exist? source then YAML.load_file source else {} end
      end

      def options
        original_options = super
        defaults_global = load_config global_config_file
        defaults_local = load_config local_config_file
        Thor::CoreExt::HashWithIndifferentAccess.new defaults_global.merge(defaults_local).merge(original_options)
      end

      def raise(message)
        super Thor::Error, set_color(message, :red)
      end

      def success(message)
        say "Yuspagara. #{message}", :green
      end
    end
  end
end
