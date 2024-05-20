require_relative '../spec_helper'

RSpec.describe DynamodbRecord::Config, :vcr do
  after do
    DynamodbRecord::Config.set_defaults
  end

  it 'has default options' do
    DynamodbRecord::Config.set_defaults
    expect(DynamodbRecord::Config.region).to eq('us-east-1')
    expect(DynamodbRecord::Config.namespace).to eq(nil)
  end

  it 'sets config options' do
    DynamodbRecord.configure do |config|
      config.access_key_id = 'key'
      config.secret_access_key = 'secret'
      config.region = 'region'
      config.namespace = 'fleteo-v2'
    end

    expect(DynamodbRecord::Config.access_key_id).to eq('key')
    expect(DynamodbRecord::Config.secret_access_key).to eq('secret')
    expect(DynamodbRecord::Config.region).to eq('region')
    expect(DynamodbRecord::Config.namespace).to eq('fleteo-v2')
  end
end
