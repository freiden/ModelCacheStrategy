module ModelCacheStrategy
  class SnsClient < SimpleDelegator
    attr_reader :topic_name
    alias :client :__getobj__

    def self.new(topic_name)
      return nil unless topic_name
      super
    end

    def initialize(topic_name:, sns_settings)
      @topic_name = topic_name
      __setobj__(Aws::SNS::Client.new)
    end

    def topic
      @topic ||= client.list_topics.topics.detect { |topic| topic.topic_arn.match(/:#{topic_name}$/) }
    end

    def publish(message_hash)
      begin
        response = client.publish({
          topic_arn: topic.topic_arn,
          message_structure: 'json',
          message: message_hash.merge({ default: 'cb_message' }).to_json
        })
        # Rails.logger.tagged('PUBLISH') { |logger| logger.debug 'RESPONSE ' + response.inspect }
        ModelCacheStrategy::logger.debug 'RESPONSE' + response.inspect
        response
      rescue Exception => e
        ModelCacheStrategy::logger.error "Publication failed due to: \n" + e.message
        ModelCacheStrategy::logger.error e.backtrace
      end
    end
  end
end