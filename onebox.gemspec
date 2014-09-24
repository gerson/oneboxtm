# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'onebox/version'

Gem::Specification.new do |spec|
  spec.name          = "onebox"
  spec.version       = Onebox::VERSION
  spec.authors       = ["Gerson Villanueva","Gustavo Delgado"]
  spec.email         = ["faillaceg@gmail.com","tavo.ucv@gmail.com"]
  spec.summary       = %q{Onebox REST SDK provides Ruby APIs to create, process and manage service form OneboxTicket.}
  spec.description   = %q{Onebox REST SDK provides Ruby APIs to create, process and manage service form OneboxTicket.}

  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
