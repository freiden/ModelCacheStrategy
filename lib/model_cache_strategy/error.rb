module ModelCacheStrategy
  class InvalidSettingsError < StandardError
    def message
      "Invalid settings parameters! " + super
    end
  end
end
