lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coppertone/version'

Gem::Specification.new do |spec|
  spec.name          = 'coppertone'
  spec.version       = Coppertone::VERSION
  spec.authors       = ['Peter M. Goldstein']
  spec.email         = ['peter@valimail.com']
  spec.summary       = 'A Sender Policy Framework (SPF) toolkit'
  spec.description   = 'Coppertone includes tools for parsing SPF DNS records, evaluating the result of SPF checks for received emails, and creating appropriate email headers from SPF results.'
  spec.homepage      = 'https://github.com/ValiMail/coppertone'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 3.0'
  spec.add_runtime_dependency 'addressable'
  spec.add_runtime_dependency 'dns_adapter'
  spec.add_runtime_dependency 'i18n'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'flay'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '>= 3.0'
end
