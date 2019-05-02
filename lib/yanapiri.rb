require 'octokit'
require 'git'
require 'thor'
require 'yaml'
require 'ostruct'

require_relative './yanapiri/version'
require_relative './yanapiri/entrega'
require_relative './yanapiri/bot'

module Yanapiri
  class CLI < Thor
    include Thor::Actions
    class_option :verbose, {type: :boolean, aliases: :v}
    class_option :orga, {aliases: :o}
    class_option :github_token

    def initialize(args = [], local_options = {}, config = {})
      super(args, local_options, config)
      @bot = Bot.new(options.orga, options.github_token)
    end

    desc 'setup', 'Configura a Yanapiri para el primer uso'
    def setup
      say '¡Kamisaraki! Yo soy Yanapiri, tu ayudante, y necesito algunos datos antes de empezar:', :bold

      config = OpenStruct.new
      config.github_token = ask 'Token de GitHub (lo necesito para armar los pull requests):'
      config.orga = ask 'Organización por defecto:'

      begin
        bot = Bot.new(config.orga, config.github_token)
        say "Yuspagara. Los pull requests serán creados por @#{bot.github_user.login}, asegurate de que tenga los permisos necesarios en las organizaciones que uses.", :green
        dump_config! config.to_h
      rescue Octokit::Unauthorized
        raise Thor::Error, set_color('El access token de GitHub no es correcto, revisalo por favor.', :red)
      end
    end

    desc 'whoami', 'Organización y usuario con el que se está trabajando'
    def whoami
      puts "Estoy trabajando en la organización #{@bot.organization}, commiteando con el usuario #{@bot.git_author}."
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

    desc 'corregir [ENTREGA]', 'Prepara la entrega para la corrección, creando los archivos y el pull request'
    option :commit_base, {required: true, aliases: :b}
    option :fecha_limite, {default: Time.now.to_s, aliases: :l}
    def corregir(nombre)
      foreach_entrega(nombre) do |entrega|
        @bot.preparar_correccion! entrega, options.commit_base
      end
    end

    desc 'ultimo_commit [ENTREGA]', 'Muestra la fecha del último commit de cada repositorio e indica si se pasó de la fecha límite'
    option :fecha_limite, {default: Time.now.to_s, aliases: :l}
    option :solo_excedidos, {type: :boolean}
    def ultimo_commit(nombre)
      foreach_entrega(nombre) do |entrega|
        if not options.solo_excedidos or entrega.fuera_de_termino?
          say entrega.mensaje_ultimo_commit, entrega.fuera_de_termino? ? :red : :clear
        end
      end
    end

    no_commands do
      def foreach_repo(dir_base)
        Dir.chdir(dir_base) do
          working_dir = Dir.pwd
          repos = Dir.glob('*').select {|f| File.directory? f}.sort

          for repo in repos
            log "Trabajando con #{repo}..."
            Dir.chdir "#{working_dir}/#{repo}" do
              yield repo, working_dir
            end
            log "==============================\n"
          end
        end
      end

      def foreach_entrega(nombre)
        foreach_repo(nombre) do |repo, base_path|
          yield Entrega.new base_path, repo, Time.parse(options.fecha_limite)
        end
      end

      def log(mensaje)
        puts mensaje if options[:verbose]
      end

      def config_file
        File.expand_path '~/.yanapiri'
      end

      def dump_config!(config)
        File.write config_file, config.to_yaml
      end

      def options
        original_options = super
        return original_options unless File.exists? config_file
        defaults = YAML.load_file config_file || {}
        Thor::CoreExt::HashWithIndifferentAccess.new defaults.merge(original_options)
      end
    end
  end
end

Yanapiri::CLI.start(ARGV)
