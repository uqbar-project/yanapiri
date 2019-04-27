$working_dir = Dir.pwd

def foreach_repo(log_enabled = true)
  repos = Dir.glob('*').select {|f| File.directory? f}.sort

  for repo in repos
    print_log log_enabled, "Trabajando con #{repo}..."
    Dir.chdir "#{$working_dir}/#{repo}"
    yield repo, $working_dir
    print_log log_enabled, "==============================\n"
  end

  Dir.chdir $working_dir
end

def print_log(enabled, message)
  puts message if enabled
end
