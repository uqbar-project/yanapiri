require 'octokit'
require 'git'

require_relative './yanapiri/foreach_repo'
require_relative './yanapiri/entrega'

Git.global_config('user.name', 'Yanapiri Bot')
Git.global_config('user.email', 'federico.aloi+yanapiribot@gmail.com')