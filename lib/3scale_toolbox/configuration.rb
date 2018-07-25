require 'yaml/store'

module ThreeScaleToolbox
  class Configuration
    def initialize(config_file)
      @store_data = nil
      @store = YAML::Store.new(config_file)
    end

    def data(key)
      store_data[key]
    end

    def update(key)
      return if key.nil?
      # invalidate cache
      @store_data = nil
      @store.transaction do
        @store[key] = yield @store[key]
      end
    end

    private

    def store_data
      @store_data ||= read
    end

    # returns copy of data stored
    def read
      @store.transaction(true) do
        @store.roots.each_with_object({}) do |key, obj|
          obj[key] = @store[key]
        end
      end
    end
  end
end
