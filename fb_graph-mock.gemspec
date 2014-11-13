Gem::Specification.new do |gem|
  gem.name          = "fb_graph-mock"
  gem.version       = File.read("VERSION").delete("\n\r")
  gem.authors       = ["nov matake"]
  gem.email         = ["nov@matake.jp"]
  gem.description   = %q{FB Graph API mocking}
  gem.summary       = %q{Let's share current FB Graph API response format for our FB Graph API related specs!}
  gem.homepage      = "http://github.com/nov/fb_graph-mock"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency "rake"
  gem.add_runtime_dependency "fb_graph"
  gem.add_runtime_dependency "rspec", "< 3"
  gem.add_runtime_dependency "webmock", "<= 1.20.2"
  gem.add_development_dependency "simplecov"
end