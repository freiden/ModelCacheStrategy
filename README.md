# ModelCacheStrategy

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'model_cache_strategy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install model_cache_strategy

## Usage
* Add an initializer for the gem into your app, defining the settings for the service your using:

```ruby
  ModelCacheStrategy.configure do |config|
    config.varnish = {
      hosts_ips: Gaston.hosts.varnish.ips,
      cache_max_age:       6.hours,
      custom_cache_header: 'X-Invalidated-By',
      worker_throttling: { threshold: 3, period: 1.second },
    }
    config.sns     = {
      region:            ENV['AWS_REGION'],
      access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      topic_name:        'topic',
    }

    config.adapters = [
      ModelCacheStrategy::Adapters::Varnish.new,
      ModelCacheStrategy::Adapters::Sns.new
    ]
  end
```
  By default the SNS settings could fallback on the AWS `classical` environment variables but it's better to declared them.

* Stragegies must be defined in the 'app/model_cache_strategies' directory of your Rails app.
* To associate a Model to a strategy:
  * Define a hook in the model class:

    ```ruby
      resource_hook :assessments
    ```

  * Declare the association into the gem initializer:

    ```ruby
      ModelCacheStrategy.register_strategy_for(:assessments, AssessmentCacheStrategy)
    ```
* Your strategies must inherit from the class DefaultCacheStrategy, defining the default behavior expecting with the managed services.
  * Your strategies must defined a protected method named *expire_cache*, using the defined adapters to expire the relateds contents:

    ```ruby
      adapters.expire!(callback_type) do |ca|
        ca.set_expiration(self.class.cache_key, resource.id)
        ca.set_expiration(ModelCacheStrategy.for(:subjects).cache_key, metasujet_ids)
        ca.set_expiration(ModelCacheStrategy.for(:msv_joins).cache_key, msv_join_ids)
      end
    ```
  * Each strategies could use independently one of the defined adapters and specified on which callback it should run:

    ```ruby
      use_adapter_for :sns,     topic_name: Gaston.sns.topic_name
      use_adapter_for :varnish
    ```

  OR

    ```ruby
      use_adapter_for :varnish, on: [:update, :delete]
    ```
* To enable the throttling functionality you need to add Sidekiq Throttler these to your Sidekiq initializer:
 ```ruby
  Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler, storage: :redis
  end
end
 ```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Vodeclic/ModelCacheStrategy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.
