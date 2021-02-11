module ThreeScaleToolbox
  module CRD
    module Metric
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
