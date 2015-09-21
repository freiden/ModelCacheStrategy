require 'aws-sdk'

module ModelCacheStrategy
  class SnsClient < SimpleDelegator
    alias :client :__getobj__

    def initialize(credentials)
      __setobj__(Aws::SNS::Client.new(credentials))
    end

    def get_topic_by_name(topic_name)
      topics.detect { |topic| topic.topic_arn.match(/:#{topic_name}$/) }
    end

    def topic_exist?(topic_name)
      !!topics.detect { |topic| topic.topic_arn.match(/:#{topic_name}$/) }
    end

    def topics
      @topics ||= client.list_topics.topics
    end

    def publish(topic_name, message_hash)
      begin
        topic = get_topic_by_name(topic_name)

        unless topic
          raise ModelCacheStrategy::UnknowTopicNameError, "Topic #{topic_name} has not been found, please check your SNS topics list!"
        end

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