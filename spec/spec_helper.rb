$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'model_cache_strategy'


RSpec.configure do |config|
  config.before(:suite) do
    ENV['AWS_REGION'] = 'xx-west-1'
    ENV['AWS_ACCESS_KEY_ID'] = 'AAAABBBBCCCCDDDDEEEEFFFFF'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'AAAbbbCCC-ddddEEE/hhh'
  end
end