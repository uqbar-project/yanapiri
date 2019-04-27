#!/usr/bin/env ruby

require_relative './lib/yanapiri'

$commit_base = ARGV[0] or raise "Necesito como parámetro el SHA del commit base (ejemplo: b7b83cd0aa3b702)."
$gh_token = ENV['GITHUB_TOKEN'] or raise "Token de GitHub no encontrado, asegurate de que está guardado en la variable de entorno $GITHUB_TOKEN. Si no tenés un token, podés generarlo en https://github.com/settings/tokens, con al menos scope 'repo'."
$organization = 'obj1-unahur-2019s1'

foreach_repo do |repo, base_path|
  entrega = Entrega.new(base_path, repo)
  entrega.preparar_correccion! $commit_base
  entrega.publicar_cambios!
  entrega.crear_pull_request! Octokit::Client.new(access_token: $gh_token), $organization
end
