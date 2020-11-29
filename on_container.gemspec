require_relative 'lib/on_container/version'

Gem::Specification.new do |spec|
  spec.name          = 'on_container'
  spec.version       = OnContainer::VERSION
  spec.authors       = ['Roberto Quintanilla']
  spec.email         = ['roberto.quintanilla@gmail.com']

  spec.summary       = %q{A small collection of scripts and routines to help ruby development within containers}
  spec.description   = %q{A small collection of scripts and routines to help ruby development within containers}
  spec.homepage      = 'https://github.com/IcaliaLabs/on-container-for-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.files         = `git ls-files -- lib/* *.md *.gemspec *.txt Rakefile`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.bindir        = 'exe'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1'
end
