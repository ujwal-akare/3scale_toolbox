module ThreeScaleToolbox
  module Helper
    def self.compare_hashes(first, second, keys)
      keys.map { |key| first.fetch(key, nil) } == keys.map { |key| second.fetch(key, nil) }
    end

    ##
    # Compute array difference with custom comparator
    def self.array_difference(ary, other_ary)
      ary.reject do |ary_elem|
        other_ary.find do |other_ary_elem|
          yield(ary_elem, other_ary_elem)
        end
      end
    end

    ##
    # Returns new hash object with not nil valid params
    def self.filter_params(valid_params, source)
      valid_params.each_with_object({}) do |key, target|
        target[key] = source[key] unless source[key].nil?
      end
    end
  end
end
