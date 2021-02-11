module ThreeScaleToolbox
  module CRD
    module BackendMetric
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
