require 'octokit'
require 'git'
require 'thor'

require_relative './yanapiri/version'
require_relative './yanapiri/entrega'
require_relative './yanapiri/bot'

module Yanapiri
  module GitUser
    def self.name
      'Yanapiri Bot'
    end

    def self.email
      'federico.aloi+yanapiribot@gmail.com'
    end

    def self.full_name
      "#{name} <#{email}>"
    end

    def self.configurar!
      Git.global_config('user.name', name)
      Git.global_config('user.email', email)
    end
  end

  class CLI < Thor
    include Thor::Actions
    class_option :verbose, {type: :boolean, aliases: :v}

    desc 'whoami', 'Organización y usuario con el que se está trabajando'
    def whoami
      puts "Estoy trabajando en la organización #{$bot.organization}, commiteando con el usuario #{GitUser.full_name}."
    end

    desc 'clonar [ENTREGA]', 'Clona todos los repositorios de la entrega dentro de una subcarpeta'
    def clonar(nombre)
      $bot.clonar_entrega!(nombre)
    end

    desc 'corregir [ENTREGA]', 'Prepara la entrega para la corrección, creando los archivos y el pull request'
    option :commit_base, {required: true, aliases: :b}
    option :fecha_limite, {default: Time.now.to_s, aliases: :l}
    def corregir(nombre)
      foreach_repo(nombre) do |repo, base_path|
        entrega = Entrega.new base_path, repo, Time.parse(options.fecha_limite)
        entrega.preparar_correccion! options.commit_base
        entrega.publicar_cambios!
        entrega.crear_pull_request! $bot
      end
    end

    desc 'ultimo_commit [ENTREGA]', 'Muestra la fecha del último commit de cada repositorio e indica si se pasó de la fecha límite'
    option :fecha_limite, {default: Time.now.to_s, aliases: :l}
    option :solo_excedidos, {type: :boolean}
    def ultimo_commit(nombre)
      foreach_repo(nombre) do |repo, base_path|
        entrega = Entrega.new base_path, repo, Time.parse(options.fecha_limite)
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

      def log(mensaje)
        puts mensaje if options[:verbose]
      end
    end
  end
end

Yanapiri::GitUser.configurar!

organization = 'obj1-unahur-2019s1'
gh_token = ENV['YANAPIRI_GH_TOKEN'] or raise "Token de GitHub no encontrado, asegurate de que está guardado en la variable de entorno YANAPIRI_GH_TOKEN. Si no tenés un token, podés generarlo en https://github.com/settings/tokens, con al menos scope 'repo'."

$bot = Bot.new(organization, gh_token)

Yanapiri::CLI.start(ARGV)
