require 'octokit'
require 'git'
require 'thor'

require_relative './yanapiri/version'
require_relative './yanapiri/foreach_repo'
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
    desc "whoami", "Organización y usuario con el que se está trabajando"
    def whoami
      puts "Estoy trabajando en la organización #{$bot.organization}, commiteando con el usuario #{GitUser.full_name}."
    end
  end
end

Yanapiri::GitUser.configurar!

organization = 'obj1-unahur-2019s1'
gh_token = ENV['YANAPIRI_GH_TOKEN'] or raise "Token de GitHub no encontrado, asegurate de que está guardado en la variable de entorno YANAPIRI_GH_TOKEN. Si no tenés un token, podés generarlo en https://github.com/settings/tokens, con al menos scope 'repo'."

$bot = Bot.new(organization, gh_token)

Yanapiri::CLI.start(ARGV)
