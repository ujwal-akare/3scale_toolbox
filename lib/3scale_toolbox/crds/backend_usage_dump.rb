module ThreeScaleToolbox
  module CRD
    module BackendUsageSerializer
      def to_cr
        {
          'path' => path
        }
      end
    end
  end
end
