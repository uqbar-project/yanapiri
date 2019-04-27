#!/usr/bin/env ruby
require 'json'
require_relative './lib/yanapiri'

raise "Necesito como parámetro la fecha y hora (ejemplo: 2019-04-24 23:59:59)." unless ARGV[0]

$fecha = ARGV[0]

foreach_repo(false) do |repo, base_path|
  entrega = Entrega.new base_path, repo, Time.parse($fecha)
  puts "#{entrega.autor} hizo su último commit el #{entrega.fecha}." if entrega.fuera_de_termino?
end
