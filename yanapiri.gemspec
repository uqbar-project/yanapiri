
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yanapiri/version"

Gem::Specification.new do |spec|
  spec.name          = "yanapiri"
  spec.version       = Yanapiri::VERSION
  spec.authors       = ["Federico Aloi"]
  spec.email         = ["federico.aloi@gmail.com"]

  spec.summary       = "Ayudante para administrar entregas via GitHub Classroom."
  spec.homepage      = "https://github.com/faloi/yanapiri"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = ["yanapiri"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "octokit", "~> 4.0"
  spec.add_dependency "git", "~> 1.5"
  spec.add_dependency "activesupport", "~> 4.2"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
