require "spec_helper"

module ModelCacheStrategy
  describe Configuration do

    let(:default_sns_settings) {
      {
        aws_region: ENV['AWS_REGION'], #'xx-west-1',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], #'AAAABBBBCCCCDDDDEEEEFFFFF',
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], #'AAAbbbCCC-ddddEEE/hhh'
      }
    }

    let(:default_varnish_settings) {
      {
        custom_cache_header: 'X-Invalidated-By',
        host: 'http://localhost',
        cache_max_age: 900
      }
    }

    describe "#varnish" do
      it "return a Hash object" do
        varnish_config = Configuration.new.varnish

        expect(varnish_config).to be
        expect(varnish_config.class).to eq(Hash)
      end

      it "return default settings without parameter" do
        varnish_config = Configuration.new.varnish

        expect(varnish_config).to eq(default_varnish_settings)
      end

      it "raise an exception when giving an invalid varnish_settings" do
        expect { Configuration.new(varnish_settings: nil) }.to raise_error(ArgumentError)
      end

      it "raise an exception when giving an invalid varnish_settings parameters" do
        settings = { host: nil, cache_max_age: nil }
        expect { Configuration.new(varnish_settings: settings) }.to raise_error(InvalidSettingsError)
      end

      it "raise an exception with unknow complementary settings" do
        settings = { complementary_host: 'red is dead' }

        expect { Configuration.new(varnish_settings: settings) }.to raise_error(ArgumentError)
      end
    end

    describe "#sns" do
      it "return a Hash object" do
        sns_config = Configuration.new.sns

        expect(sns_config).to be
        expect(sns_config.class).to eq(Hash)
      end

      it "return default settings without parameter" do
        sns_config = Configuration.new.sns

        expect(sns_config).to eq(default_sns_settings)
      end

      it "raise an exception when giving an invalid sns_settings" do
        expect { Configuration.new(sns_settings: nil) }.to raise_error(ArgumentError)
      end

      it "raise an exception when giving an invalid sns_settings parameters" do
        settings = { aws_region: nil, aws_access_key_id: nil }
        expect { Configuration.new(sns_settings: settings) }.to raise_error(InvalidSettingsError)
      end

      it "raise an exception without sns_settings parameters and ENV variables defined" do
        settings = {}
        allow(ENV).to receive(:[]).with('AWS_REGION').and_return(nil)
        allow(ENV).to receive(:[]).with('AWS_ACCESS_KEY_ID').and_return(nil)
        allow(ENV).to receive(:[]).with('AWS_SECRET_ACCESS_KEY').and_return(nil)

        expect { Configuration.new(sns_settings: settings) }.to raise_error(InvalidSettingsError)
      end

      it "raise an exception with unknow complementary settings" do
        settings = { complementary_host: 'red is dead' }

        expect { Configuration.new(sns_settings: settings) }.to raise_error(ArgumentError)
      end
    end

  end

end