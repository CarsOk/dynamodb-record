# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamodb_record/version'

Gem::Specification.new do |spec|
  spec.name = 'dynamodb_record'
  spec.version = DynamodbRecord::VERSION
  spec.author = ['Henry Guzman', 'Jhon Santander']
  spec.email = ['hguzman10@gmail.com', 'jsantander1219@gmail.com']
  spec.summary = 'A simple DynamoDB ORM'
  spec.homepage = 'https://github.com/CarsOk/dynamodb-record'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 7.1', '>= 7.1.3.2'
  spec.add_dependency 'aws-sdk-dynamodb', '~> 1.105'
  spec.add_dependency 'aws-sdk-sqs', '~> 1.70'
  spec.add_dependency 'jwt', '~> 2.8', '>= 2.8.1'
  spec.add_dependency 'rexml', '~> 3.2', '>= 3.2.6'

  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 1.62'
  spec.add_development_dependency 'vcr', '~> 6.2'
  spec.add_development_dependency 'webmock', '~> 3.23'
end
