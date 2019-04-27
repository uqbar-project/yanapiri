#!/usr/bin/env ruby

require_relative './lib/yanapiri'

raise "Necesito como parámetro la fecha y hora (ejemplo: 2019-04-24 23:59:59)." unless ARGV[0]

$fecha = ARGV[0]

foreach_repo(false) do
  resultado = `git --no-pager log --date=local --after="#{$fecha}" --pretty`
  puts resultado if not resultado.strip.empty?
end
