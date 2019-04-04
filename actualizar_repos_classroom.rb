$base_slug = ARGV[0]
$base_repo = $base_slug.split('/').last
$working_dir = Dir.pwd

def foreach_repo
  repos = Dir.glob('*').select {|f| File.directory? f}

  for repo in repos
    puts "Trabajando con #{repo}..."
    Dir.chdir "#{$working_dir}/#{repo}"
    yield repo
    puts ""
  end
end

`git clone git@github.com:#{$base_slug}.git`

foreach_repo do
  `git remote rm base`
  `git remote add base ../#{$base_repo}`
  `git pull base master`
  `git push origin master`
end
