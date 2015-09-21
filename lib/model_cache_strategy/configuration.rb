module ModelCacheStrategy
  class Configuration
    attr_accessor :varnish, :sns
    # attr_reader   :sns_client

    def initialize(varnish_settings: {}, sns_settings: {}, adapters: [])
      @varnish    = set_varnish_settings(varnish_settings)
      @sns        = set_sns_settings(sns_settings)
      @sns_client = get_sns_client
      @adapters   = set_adapters(adapters)
    end

    def adapters
      @adapters
    end

    def adapters=(adapters = [])
      @adapters = set_adapters(adapters)
    end

    def sns
      @sns
    end

    def sns=(sns_settings = {})
      @sns = set_sns_settings(sns_settings)
    end

    def sns_client
      @sns_client ||= get_sns_client
    end

    def varnish
      @varnish
    end

    def varnish=(varnish_settings = {})
      @varnish = set_varnish_settings(varnish_settings)
    end


  private

    def get_sns_client
      SnsClient.new(sns.select { |k,v| :topic_name != k }) #if sns.values.any? { |value| value.present? }
    end

    def set_adapters(adapters)
      ModelCacheStrategy::AdaptersProxy.new(adapters)
    end

    def set_sns_settings(region: ENV['AWS_REGION'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], topic_name: nil)
      sns_settings = { region: region, access_key_id: access_key_id, secret_access_key: secret_access_key, topic_name: topic_name }

      raise InvalidSettingsError, error_message(:sns, sns_settings) if sns_settings.any? { |(key, value)| value.blank? && :topic_name != key }

      sns_settings
    end

    def set_varnish_settings(custom_cache_header: 'X-Invalidated-By', host: 'http://localhost', cache_max_age: 900)
      varnish_settings = { custom_cache_header: custom_cache_header.freeze, host: host.freeze, cache_max_age: cache_max_age }

      raise InvalidSettingsError, error_message(:varnish, varnish_settings) if varnish_settings.values.any? { |value| value.blank? }

      varnish_settings
    end

    def mcs_logger(level = :info, message:, additional: nil)
      logger_message = message
      logger_message << "\n#{additional}" if additional.present?
      # ModelCacheStrategy::logger.tagged('ModelCacheStrategy') { |logger| logger.send(level, logger_message) }
      ModelCacheStrategy::logger.send(level, logger_message)
    end

    def error_message(setting_type, parameters)
      message = "The settings for #{setting_type} are invalid: #{parameters}! Please verify them."
    end

  end
end