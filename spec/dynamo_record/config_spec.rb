require 'spec_helper'

RSpec.describe DynamoRecord::Config do

  after do
    DynamoRecord::Config.set_defaults
  end

  it 'has default options' do
    expect(DynamoRecord::Config.region).to eq('us-east-1')
  end

  it 'sets config options' do
    DynamoRecord.configure do |config|
      config.access_key_id = 'key'
      config.secret_access_key = 'secret'
      config.region = 'region'
    end

    expect(DynamoRecord::Config.access_key_id).to eq('key')
    expect(DynamoRecord::Config.secret_access_key).to eq('secret')
    expect(DynamoRecord::Config.region).to eq('region')
  end

end