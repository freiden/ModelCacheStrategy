require 'spec_helper'
require 'pry'
require 'pry-byebug'

describe ModelCacheStrategy do
  let(:varnish_settings) {
    {
      host: 'http://localhost',
      custom_cache_header: 'X-Invalidated-By',
      cache_max_age: 6.hours,
    }
  }

  let(:sns_settings) {
    {
      region: 'xx-east-1',
      access_key_id: 'AAAABBBBCCCCDDDDEEEEFFFFF',
      secret_access_key: 'AAAbbbCCC-ddddEEE/hhh',
      topic_name: 'test-topic',
    }
  }

  let(:varnish_default_settings) {
    {
      host: 'http://localhost',
      custom_cache_header: 'X-Invalidated-By',
      cache_max_age: 900,
    }
  }

  let(:sns_default_settings) {
    {
      region: 'xx-west-1',
      access_key_id: 'AAAABBBBCCCCDDDDEEEEFFFFF',
      secret_access_key: 'AAAbbbCCC-ddddEEE/hhh',
      topic_name: nil,
    }
  }

  before(:each) do
    ModelCacheStrategy.configure do |config|
      config.varnish = varnish_settings
      config.sns     = sns_settings
    end
  end

  it 'has a version number' do
    expect(ModelCacheStrategy::VERSION).not_to be nil
  end

  describe "#configure" do
    it "returns settings for varnish settings" do
      varnish_configuration = ModelCacheStrategy.configuration.varnish
      expect(varnish_configuration).to be_truthy
      expect(varnish_configuration).to eq(varnish_settings)
    end

    it "returns settings for sns settings" do
      sns_configuration = ModelCacheStrategy.configuration.sns
      expect(sns_configuration).to be_truthy
      expect(sns_configuration).to eq(sns_settings)
    end
  end

  describe "#sns_client" do
    it "returns a valid instance of sns_client" do
      config = ModelCacheStrategy.configuration
      expect(config.sns_client).to be_truthy
      expect(config.sns_client.class).to eql(ModelCacheStrategy::SnsClient)
    end
  end

  describe "#reset" do
    it "resets the configuration" do
      ModelCacheStrategy.reset

      config = ModelCacheStrategy.configuration

      expect(config.varnish).to eq(varnish_default_settings)
      expect(config.sns).to eq(sns_default_settings)
    end
  end

end
