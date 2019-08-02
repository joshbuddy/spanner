
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "spanner/version"

Gem::Specification.new do |spec|
  spec.name = "spanner"
  spec.version = Spanner::VERSION
  spec.authors = ["joshbuddy"]
  spec.email = ["joshbuddy@gmail.com"]

  spec.summary = "Natural language time span parsing"
  spec.description = "Natural language time span parsing"
  spec.homepage = "https://github.com/joshbuddy/spanner"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"
end
