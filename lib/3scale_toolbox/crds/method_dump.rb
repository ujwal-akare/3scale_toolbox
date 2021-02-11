module ThreeScaleToolbox
  module CRD
    module Method
      def to_cr
        {
          'friendlyName' => friendly_name,
          'description' => description,
        }
      end
    end
  end
end
