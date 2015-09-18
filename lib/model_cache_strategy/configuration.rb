module ModelCacheStrategy
  class Configuration
    attr_accessor :varnish, :sns

    def initialize(varnish_settings: {}, sns_settings: {})
      binding.pry
      @varnish = set_varnish_settings(varnish_settings)
      @sns     = set_sns_settings(sns_settings)
    end

    def varnish
      @varnish
    end

    def varnish=(varnish_settings = {})
      @varnish = set_varnish_settings(varnish_settings)
    end

    def sns
      @sns
    end

    def sns=(sns_settings = {})
      @sns = set_sns_settings(sns_settings)
    end


  private
    def set_varnish_settings(custom_cache_header: 'X-Invalidated-By', host: 'http://localhost', cache_max_age: 900)
      varnish_settings = { custom_cache_header: custom_cache_header.freeze, host: host.freeze, cache_max_age: cache_max_age }

      raise InvalidSettingsError, error_message(:varnish, varnish_settings) if varnish_settings.values.any? { |value| value.blank? }

      varnish_settings
    end

    def set_sns_settings(aws_region: ENV['AWS_REGION'], aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
      sns_settings = { aws_region: aws_region, aws_access_key_id: aws_access_key_id, aws_secret_access_key: aws_secret_access_key }

      raise InvalidSettingsError, error_message(:sns, sns_settings) if sns_settings.values.any? { |value| value.blank? }

      sns_settings
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