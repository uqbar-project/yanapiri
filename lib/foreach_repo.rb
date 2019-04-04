$working_dir = Dir.pwd

def foreach_repo
  repos = Dir.glob('*').select {|f| File.directory? f}

  for repo in repos
    puts "Trabajando con #{repo}..."
    Dir.chdir "#{$working_dir}/#{repo}"
    yield repo
    puts ""
  end

  Dir.chdir $working_dir
end
