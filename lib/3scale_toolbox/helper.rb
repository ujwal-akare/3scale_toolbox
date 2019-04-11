module ThreeScaleToolbox
  module Helper
    class << self
      def compare_hashes(first, second, keys)
        keys.map { |key| first.fetch(key, nil) } == keys.map { |key| second.fetch(key, nil) }
      end

      ##
      # Compute array difference with custom comparator
      def array_difference(ary, other_ary)
        ary.reject do |ary_elem|
          other_ary.find do |other_ary_elem|
            yield(ary_elem, other_ary_elem)
          end
        end
      end

      ##
      # Returns new hash object with not nil valid params
      def filter_params(valid_params, source)
        valid_params.each_with_object({}) do |key, target|
          target[key] = source[key] unless source[key].nil?
        end
      end

      def parse_uri(uri)
        # raises error when remote_str is not string, but object or something else.
        uri_obj = URI(uri)
        # URI::HTTP is parent of URI::HTTPS
        # with single check both types are checked
        raise ThreeScaleToolbox::InvalidUrlError, "invalid url: #{uri}" unless uri_obj.kind_of?(URI::HTTP)

        uri_obj
      end

      def service_invalid_deployment_option?(error)
        Array(Hash(error)['deployment_option']).any? do |msg|
          msg.match(/is not included in the list/)
        end
      end

      def system_name_already_taken_error?(error)
        Array(Hash(error)['system_name']).any? { |msg| msg.match(/has already been taken/) }
      end

      def period_already_taken_error?(error)
        Array(Hash(error)['period']).any? { |msg| msg.match(/has already been taken/) }
      end
    end
  end
end
