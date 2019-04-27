#!/usr/bin/env ruby

require_relative './lib/yanapiri'

commit_base = ARGV[0] or raise "Necesito como primer parámetro el SHA del commit base (ejemplo: b7b83cd0aa3b702)."
fecha_limite = ARGV[1] or raise "Necesito como segundo parámetro la fecha de entrega (ejemplo: 2019-04-24 23:59:59)."

foreach_repo do |repo, base_path|
  entrega = Entrega.new base_path, repo, Time.parse(fecha_limite)
  entrega.preparar_correccion! commit_base
  entrega.publicar_cambios!
  entrega.crear_pull_request! $bot
end
