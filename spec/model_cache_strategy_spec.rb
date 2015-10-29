require 'spec_helper'
require 'pry'
require 'pry-byebug'

describe ModelCacheStrategy do
  let(:varnish_settings) {
    {
      hosts_ips: %w(127.0.0.1),
      custom_cache_header: 'X-Invalidated-By',
      cache_max_age: 6.hours,
      varnish_port: 80,
      worker_throttling: { threshold: 10, period: 1.minute },
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
      custom_cache_header: 'X-Invalidated-By',
      hosts_ips: Array(ModelCacheStrategy::Configuration::DEFAULT_HOSTS_IPS),
      cache_max_age: ModelCacheStrategy::Configuration::DEFAULT_CACHE_MAX_AGE,
      varnish_port: ModelCacheStrategy::Configuration::DEFAULT_VARNISH_PORT,
      worker_throttling: ModelCacheStrategy::Configuration::DEFAULT_THROTTLING_SETTINGS
    }
  }

  let(:sns_default_settings) {
    {
      region: ENV['AWS_REGION'], #'xx-west-1',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'], #'AAAABBBBCCCCDDDDEEEEFFFFF',
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], #'AAAbbbCCC-ddddEEE/hhh',
      topic_name: nil,
    }
  }

  before(:each) do
    ModelCacheStrategy.configure do |config|
      config.varnish  = varnish_settings
      config.sns      = sns_settings
      config.adapters = [
        ModelCacheStrategy::Adapters::Varnish,
        ModelCacheStrategy::Adapters::Sns,
      ]
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

      expect(config.varnish).to be_nil
      expect(config.sns).to be_nil
    end
  end

end
