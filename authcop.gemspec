# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authcop/version'

Gem::Specification.new do |gem|
  gem.name          = "authcop"
  gem.version       = AuthCop::VERSION
  gem.authors       = ["Juan Wajnerman", "Ary Borenszweig"]
  gem.email         = ["jwajnerman@manas.com.ar", "aborenszweig@manas.com.ar"]
  gem.description   = %q{Authorization cop}
  gem.summary       = %q{Never forget to scope an ActiveRecord query for the current user}
  gem.homepage      = "https://github.com/manastech/authcop"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
