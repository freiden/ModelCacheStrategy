module ModelCacheStrategy
  class InvalidSettingsError < StandardError
    def message
      "Invalid settings parameters! " + super
    end
  end

  class UnknowTopicNameError < StandardError
    def message
      "Unknow topic name!" + super
    end
  end
end
