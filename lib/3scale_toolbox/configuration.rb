require 'yaml/store'

module ThreeScaleToolbox
  class Configuration
    def initialize(config_file)
      @store = YAML::Store.new(config_file)
    end

    def data(key)
      read[key]
    end

    def update(key)
      return if key.nil?
      @store.transaction do
        @store[key] = yield @store[key]
      end
    end

    private

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
