require 'octokit'
require 'git'
require 'thor'

require_relative './yanapiri/version'
require_relative './yanapiri/entrega'
require_relative './yanapiri/bot'

module Yanapiri
  class CLI < Thor
    include Thor::Actions
    class_option :verbose, {type: :boolean, aliases: :v}

    desc 'whoami', 'Organización y usuario con el que se está trabajando'
    def whoami
      puts "Estoy trabajando en la organización #{$bot.organization}, commiteando con el usuario #{$bot.git_author}."
    end

    desc 'clonar [ENTREGA]', 'Clona todos los repositorios de la entrega dentro de una subcarpeta'
    def clonar(nombre)
      $bot.clonar_entrega!(nombre)
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
        $bot.preparar_correccion! entrega, options.commit_base
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
    end
  end
end

organization = 'obj1-unahur-2019s1'
gh_token = ENV['YANAPIRI_GH_TOKEN'] or raise "Token de GitHub no encontrado, asegurate de que está guardado en la variable de entorno YANAPIRI_GH_TOKEN. Si no tenés un token, podés generarlo en https://github.com/settings/tokens, con al menos scope 'repo'."

$bot = Bot.new(organization, gh_token)

Yanapiri::CLI.start(ARGV)
