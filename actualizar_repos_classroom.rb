#!/usr/bin/env ruby

require_relative './lib/foreach_repo'

raise "Necesito como parámetro el slug del repositorio base (ejemplo: wollok/multipepita)." unless ARGV[0]

$base_slug = ARGV[0]
$base_repo = $base_slug.split('/').last

`git clone git@github.com:#{$base_slug}.git`

foreach_repo do
  `git remote rm base`
  `git remote add base ../#{$base_repo}`
  `git pull base master`
  `git push origin master`
end
