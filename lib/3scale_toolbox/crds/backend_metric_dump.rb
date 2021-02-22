module ThreeScaleToolbox
  module CRD
    module BackendMetricSerializer
      def to_cr
        {
          'friendlyName' => friendly_name,
          'unit' => unit,
          'description' => description,
        }
      end
    end
  end
end
