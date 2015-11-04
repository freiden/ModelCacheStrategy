require "spec_helper"
require 'pry'
require 'pry-byebug'

module ModelCacheStrategy
  describe Configuration do
    let(:varnish_adapter) { ModelCacheStrategy::Adapters::Varnish }
    let(:sns_adapter)     { ModelCacheStrategy::Adapters::Sns }

    let(:default_sns_settings) {
      {
        region: ENV['AWS_REGION'], #'xx-west-1',
        access_key_id: ENV['AWS_ACCESS_KEY_ID'], #'AAAABBBBCCCCDDDDEEEEFFFFF',
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], #'AAAbbbCCC-ddddEEE/hhh',
        topic_name: nil,
      }
    }

    let(:default_varnish_settings) {
      {
        custom_cache_header: 'X-Invalidated-By',
        hosts_ips: Array(ModelCacheStrategy::Configuration::DEFAULT_HOSTS_IPS),
        cache_max_age: ModelCacheStrategy::Configuration::DEFAULT_CACHE_MAX_AGE,
        varnish_port: ModelCacheStrategy::Configuration::DEFAULT_VARNISH_PORT,
        worker_throttling: {}
      }
    }

    describe "#adapters" do
      it 'return an AdaptersProxy object' do
        adapters = [varnish_adapter, sns_adapter]
        initial_config = Configuration.new(adapters: adapters)

        expect(initial_config.adapters).to be
        expect(initial_config.adapters.class).to eq(ModelCacheStrategy::AdaptersProxy)
      end

      it "return objects related to passed adapters" do
        adapters = [varnish_adapter, sns_adapter]
        initial_config = Configuration.new(adapters: adapters)

        expect(initial_config.adapters.type).to match_array(adapters.map(&:type))
      end

      it 'return an empty without given adapters' do
        initial_config = Configuration.new

        expect(initial_config.adapters).to eq([])
      end
    end

    describe "#varnish" do
      context 'without related adapter at init' do
        it "return a Nil object" do
          initial_config = Configuration.new
          varnish_config = initial_config.varnish

          expect(varnish_config).to be_nil
        end

        it 'log a warn message when settings the varnish settings' do
          expect(ModelCacheStrategy::logger).to receive(:warn)

          initial_config = Configuration.new
          initial_config.varnish = default_varnish_settings
          initial_config.varnish
        end

        it "doesn't set the varnish settings without the related adapter" do
          initial_config = Configuration.new
          initial_config.varnish = default_varnish_settings
          varnish_config = initial_config.varnish

          expect(varnish_config).to be_nil
        end
      end

      context 'with related adapter at init' do
        it "return a Hash object" do
          initial_config = Configuration.new(adapters: [varnish_adapter])
          varnish_config = initial_config.varnish

          expect(varnish_config).to be
          expect(varnish_config.class).to eq(Hash)
        end

        it "return default settings without parameter" do
          initial_config = Configuration.new(adapters: [varnish_adapter])
          varnish_config = initial_config.varnish

          expect(varnish_config).to eq(default_varnish_settings)
        end

        it "raise an exception when giving an invalid varnish_settings" do
          expect { Configuration.new(varnish_settings: nil, adapters: [varnish_adapter]) }.to raise_error(ArgumentError)
        end

        it "raise an exception when giving an invalid varnish_settings parameters" do
          settings = { hosts_ips: nil, cache_max_age: nil }
          expect {
            Configuration.new(varnish_settings: settings, adapters: [varnish_adapter])
          }.to raise_error(InvalidSettingsError)
        end

        it "raise an exception with unknow complementary settings" do
          settings = { complementary_host: 'red is dead' }

          expect {
            Configuration.new(varnish_settings: settings, adapters: [varnish_adapter])
          }.to raise_error(ArgumentError)
        end
      end
    end

    describe "#sns" do
      context 'without related adapter at init' do
        it "return a Nil object" do
          initial_config = Configuration.new
          sns_config = initial_config.sns

          expect(sns_config).to be_nil
        end

        it 'log a warn message when settings the sns settings' do
          expect(ModelCacheStrategy::logger).to receive(:warn)

          initial_config = Configuration.new
          initial_config.sns = default_sns_settings
          initial_config.sns
        end

        it "doesn't set the sns settings without the related adapter" do
          initial_config = Configuration.new
          initial_config.sns = default_sns_settings
          sns_config = initial_config.sns

          expect(sns_config).to be_nil
        end
      end

      context 'with related adapter at init' do
        it "return a Hash object" do
          sns_config = Configuration.new(adapters: [sns_adapter]).sns

          expect(sns_config).to be
          expect(sns_config.class).to eq(Hash)
        end

        it "return default settings without parameter" do
          sns_config = Configuration.new(adapters: [sns_adapter]).sns

          expect(sns_config).to eq(default_sns_settings)
        end

        it "raise an exception when giving an invalid sns_settings" do
          expect { Configuration.new(sns_settings: nil, adapters: [sns_adapter]) }.to raise_error(ArgumentError)
        end

        it "raise an exception when giving an invalid sns_settings parameters" do
          settings = { region: nil, access_key_id: nil }
          expect { Configuration.new(sns_settings: settings, adapters: [sns_adapter]) }.to raise_error(InvalidSettingsError)
        end

        it "raise an exception without sns_settings parameters and ENV variables defined" do
          settings = {}
          allow(ENV).to receive(:[]).with('AWS_REGION').and_return(nil)
          allow(ENV).to receive(:[]).with('AWS_ACCESS_KEY_ID').and_return(nil)
          allow(ENV).to receive(:[]).with('AWS_SECRET_ACCESS_KEY').and_return(nil)

          expect {
            Configuration.new(sns_settings: settings, adapters: [sns_adapter])
          }.to raise_error(InvalidSettingsError)
        end

        it "raise an exception with unknow complementary settings" do
          settings = { complementary_host: 'red is dead' }

          expect {
            Configuration.new(sns_settings: settings, adapters: [sns_adapter])
          }.to raise_error(ArgumentError)
        end

        it "has the topic_name when given " do
          settings = default_sns_settings.merge(topic_name: 'red is dead')
          config = Configuration.new(sns_settings: settings, adapters: [sns_adapter])

          expect(config.sns[:topic_name]).to eql(settings[:topic_name])
        end
      end

    end

  end

end