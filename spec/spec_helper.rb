# frozen_string_literal: true

require 'dynamodb_record'

MODELS = File.join(File.dirname(__FILE__), 'app/models')
Dir[File.join(MODELS, '*.rb')].sort.each { |file| require file }

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = { match_requests_on: %i[method uri body] }
end

DynamodbRecord.configure do |config|
  config.namespace = nil
  config.endpoint = 'http://localhost:8000'
end
