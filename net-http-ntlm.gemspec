# frozen_string_literal: true

require_relative 'lib/net/http/ntlm/version'

Gem::Specification.new do |spec|
  spec.name          = 'net-http-ntlm'
  spec.version       = Net::HTTP::NTLM::VERSION
  spec.authors       = ['Simon Schmid']
  spec.email         = ['simon@at-point.ch']

  spec.summary       = 'NTLM authentication for Net::HTTP'
  spec.description   = 'Adds NTLM authentication support for Net::HTTP using rubyntlm'
  spec.homepage      = 'https://github.com/at-point/net-http-ntlm'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/at-point/net-http-ntlm'
  spec.metadata['changelog_uri'] = 'https://github.com/at-point/net-http-ntlm/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|etc)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rubyntlm', '~> 0.6'

  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'

end
