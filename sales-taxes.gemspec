# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'sales-taxes'
  spec.version = '1.0.0'
  spec.authors = ['Mauricio Zaffari']
  spec.summary = 'Calculate sales taxes and print shopping basket receipts.'
  spec.required_ruby_version = '>= 4.0'
  spec.files = Dir['lib/**/*.rb', 'bin/receipts', 'examples/*.txt', 'README.md']
  spec.bindir = 'bin'
  spec.executables = ['receipts']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
