module ModelCacheStrategy
  class Configuration
    attr_reader :varnish, :sns, :adapters

    DEFAULT_CACHE_MAX_AGE       = 900
    DEFAULT_CUSTOM_CACHE_HEADER = 'X-Invalidated-By'.freeze
    DEFAULT_HOSTS_IPS           = '127.0.0.1'.freeze
    DEFAULT_VARNISH_PORT        = 80


    def initialize(varnish_settings: {}, sns_settings: {}, adapters: [])
      @adapters   = set_adapters(adapters)
      @varnish    = set_varnish_settings(varnish_settings) if has_varnish_adapter?
      @sns        = set_sns_settings(sns_settings)         if has_sns_adapter?
      @sns_client = get_sns_client                         if has_sns_adapter?
    end

    # def adapters
    #   @adapters
    # end

    def adapters=(adapters = [])
      @adapters = set_adapters(adapters)
    end

    # def sns
    #   @sns
    # end

    def sns=(sns_settings = {})
      @sns = if has_sns_adapter?
        set_sns_settings(sns_settings)
      else
        mcs_logger(:warn, message: "Sns Adapter is missing, the Sns Strategy can't be used without it!")
        nil
      end

    end

    def sns_client
      @sns_client ||= get_sns_client
    end

    # def varnish
    #   @varnish
    # end

    def varnish=(varnish_settings = {})
      @varnish = if has_varnish_adapter?
        set_varnish_settings(varnish_settings)
      else
        mcs_logger(:warn, message: "Varnish Adapter is missing, the Varnish Strategy can't be used without it!")
        nil
      end
    end


  private

    def get_sns_client
      return nil unless sns.present?

      SnsClient.new(sns.select { |k,v| :topic_name != k }) #if sns.values.any? { |value| value.present? }
    end

    def has_varnish_adapter?
      adapters.any? { |adapter| :varnish == adapter.type }
    end

    def has_sns_adapter?
      adapters.any? { |adapter| :sns == adapter.type }
    end

    def set_adapters(adapters)
      ModelCacheStrategy::AdaptersProxy.new(adapters)
    end

    def set_sns_settings(region: ENV['AWS_REGION'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], topic_name: nil)
      sns_settings = { region: region, access_key_id: access_key_id, secret_access_key: secret_access_key, topic_name: topic_name }

      if (sns_settings.any? { |(key, value)| value.blank? && :topic_name != key })
        raise InvalidSettingsError, error_message(:sns, sns_settings)
      end

      sns_settings
    end

    def set_varnish_settings(custom_cache_header: DEFAULT_CUSTOM_CACHE_HEADER, hosts_ips: DEFAULT_HOSTS_IPS, cache_max_age: DEFAULT_CACHE_MAX_AGE, varnish_port: DEFAULT_VARNISH_PORT)
      varnish_settings = {
        custom_cache_header: custom_cache_header.freeze,
        hosts_ips: Array(hosts_ips),
        varnish_port: varnish_port,
        cache_max_age: cache_max_age,
      }

      raise InvalidSettingsError, error_message(:varnish, varnish_settings) if varnish_settings.values.any? { |value| value.blank? }

      varnish_settings
    end


    ########################################### Logging message management ###########################################

    def error_message(setting_type, parameters)
      message = "The settings for #{setting_type} are invalid: #{parameters}! Please verify them."
    end

    def mcs_logger(level = :info, message:, additional: nil)
      logger_message = message
      logger_message << "\n#{additional}" if additional.present?
      ModelCacheStrategy::logger.send(level, logger_message)
    end

  end
end