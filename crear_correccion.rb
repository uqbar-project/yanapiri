#!/usr/bin/env ruby

require_relative './lib/yanapiri'

$base_commit = ARGV[0] or raise "Necesito como parámetro el SHA del commit base (ejemplo: b7b83cd0aa3b702)."
$gh_token = ENV['GITHUB_TOKEN'] or raise "Token de GitHub no encontrado, asegurate de que está guardado en la variable de entorno $GITHUB_TOKEN. Si no tenés un token, podés generarlo en https://github.com/settings/tokens, con al menos scope 'repo'."
$organization = 'obj1-unahur-2019s1'

gh_client = Octokit::Client.new(access_token: $gh_token)

def renombrar_proyecto(base_path, repo)
  archivo = "#{base_path}/#{repo}/.project"
  xml = File.read archivo
  File.open(archivo, "w") {|file| file.puts xml.sub(/<name>.*<\/name>/, "<name>#{repo}</name>") }
end

def crear_branch_base
  `git checkout #{$base_commit}`
  `git checkout -b base`
end

def crear_branch_entrega
  `git checkout master`
  # `git checkout `git rev-list -n 1 --first-parent --before="2019-04-24 23:59:59" master``
  `git checkout -b entrega`
  `git checkout entrega`
end

foreach_repo do |repo, base_path|
  crear_branch_base
  crear_branch_entrega
  renombrar_proyecto base_path, repo
  `git add .project`
  `git commit -m "Renombrado proyecto Eclipse"`

  `git push --all origin`
  gh_client.create_pull_request("#{$organization}/#{repo}", "base", "entrega", "Corrección") rescue nil
end
