require 'octokit'
require 'git'

require_relative './yanapiri/foreach_repo'
require_relative './yanapiri/entrega'
require_relative './yanapiri/bot'

Git.global_config('user.name', 'Yanapiri Bot')
Git.global_config('user.email', 'federico.aloi+yanapiribot@gmail.com')

organization = 'obj1-unahur-2019s1'
gh_token = ENV['YANAPIRI_GH_TOKEN'] or raise "Token de GitHub no encontrado, asegurate de que está guardado en la variable de entorno YANAPIRI_GH_TOKEN. Si no tenés un token, podés generarlo en https://github.com/settings/tokens, con al menos scope 'repo'."

$bot = Bot.new(organization, gh_token)