#!/usr/bin/env ruby

require_relative './lib/yanapiri'

fecha = ARGV[0] or raise "Necesito como parámetro la fecha y hora (ejemplo: 2019-04-24 23:59:59)."

foreach_repo(false) do |repo, base_path|
  entrega = Entrega.new base_path, repo, Time.parse(fecha)
  puts "#{entrega.autor} hizo su último commit el #{entrega.fecha}." if entrega.fuera_de_termino?
end
