module ThreeScaleToolbox
  module Tasks
    module CallableTask
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def call(*args)
          new(*args).call
        end
      end
    end
  end
end
