#!/usr/bin/env ruby

require_relative './lib/foreach_repo'

raise "Necesito como parámetro la fecha y hora (ejemplo: 2019-04-24 23:59:59)." unless ARGV[0]

$fecha = ARGV[0]

foreach_repo(false) do
  puts `git --no-pager log --date=local --after="#{$fecha}" --pretty`
end
