require 'yaml/store'

module ThreeScaleToolbox
  class Configuration
    ATTRIBUTES = %i[remotes].freeze
    private_constant :ATTRIBUTES

    def initialize
      @store = YAML::Store.new(ThreeScaleToolbox.config_file)
    end

    def remotes
      data.fetch(:remotes) || {}
    end

    def update_remotes
      update(:remotes, &Proc.new)
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
