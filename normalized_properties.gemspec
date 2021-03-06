require_relative 'lib/all/normalized_properties/version'

Gem::Specification.new do |spec|
  spec.name          = "normalized_properties"
  spec.version       = NormalizedProperties::VERSION
  spec.summary       = %q{Normalized properties for models}
  spec.description   = %q{Normalized properties for models}

  spec.homepage      = "https://github.com/christopheraue/m-ruby-normalized_properties"
  spec.license       = "Apache-2.0"
  spec.authors       = ["Christopher Aue"]
  spec.email         = ["rubygems@christopheraue.net"]

  spec.files         = `git ls-files -z`.split("\x0").reject{ |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib/CRuby"]

  spec.add_dependency "callbacks_attachable", "~> 3.0"
end
