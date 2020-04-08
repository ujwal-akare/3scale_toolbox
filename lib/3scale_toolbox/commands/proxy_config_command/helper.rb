module ThreeScaleToolbox
  module Commands
    module ProxyConfigCommand
      class EnvironmentTransformer
        def call(param_str)
          raise ArgumentError unless param_str.is_a?(String)

          raise ArgumentError unless %w[production sandbox].include? param_str

          param_str
        end
      end
    end
  end
end
