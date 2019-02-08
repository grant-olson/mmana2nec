
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mmana2nec/version"

Gem::Specification.new do |spec|
  spec.name          = "mmana2nec"
  spec.version       = Mmana2nec::VERSION
  spec.authors       = ["Grant T. Olson"]
  spec.email         = ["kgo@grant-olson.net"]

  spec.summary       = "Utility to convert various antenna model formats."
  spec.homepage      = "https://github.com/grant-olson/mmana2nec"

  spec.license = "BSD-3-Clause"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "optimist", "~> 3.0"
  
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
