#!/usr/bin/env ruby

require_relative './lib/yanapiri'

nombre_entrega = ARGV[0] or raise "Necesito como primer parámetro el nombre de la entrega (ejemplo: spa)."

$bot.clonar_entrega!(nombre_entrega)
