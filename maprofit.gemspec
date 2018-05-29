
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "maprofit/version"

Gem::Specification.new do |spec|
  spec.name          = "maprofit"
  spec.version       = Maprofit::VERSION
  spec.authors       = ["Felix Wolfsteller"]
  spec.email         = ["felix.wolfsteller@gmail.com"]

  spec.summary       = %q{Magento 2 profit analysis}
  spec.description   = %q{Magento 2 profit analysis web interface}
  #spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "roda"
  spec.add_dependency "roda-basic-auth"
  spec.add_dependency "oj"
  spec.add_dependency "haml"
  spec.add_dependency "hashie"
  spec.add_dependency "inflecto"
  spec.add_dependency "puma"
  spec.add_dependency "attr_extras"
  spec.add_dependency "mysql2"
  spec.add_dependency "awesome_print"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rerun"
  spec.add_development_dependency "minitest"
end
