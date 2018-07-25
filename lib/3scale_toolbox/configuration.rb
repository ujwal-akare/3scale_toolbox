require 'yaml/store'

module ThreeScaleToolbox
  class Configuration
    ATTRIBUTES = %i[remotes].freeze
    private_constant :ATTRIBUTES

    def initialize(config_file)
      @store = YAML::Store.new(config_file)
    end

    ATTRIBUTES.each do |attr|
      define_method attr do
        data.fetch(attr) || {}
      end

      define_method "update_#{attr}" do |&block|
        update(attr, &block)
      end
    end

    private

    def data
      @store_data ||= read
    end

    def update(key)
      # clear dirty cache
      @store_data = nil
      @store.transaction do
        val = @store.fetch(key, {})
        yield val
        @store[key] = val
      end
    end

    # returns copy of data stored
    def read
      @store.transaction(true) do
        ATTRIBUTES.each_with_object({}) do |key, obj|
          obj[key] = @store[key]
        end
      end
    end
  end
end
