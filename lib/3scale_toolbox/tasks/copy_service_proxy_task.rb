module ThreeScaleToolbox
  module Tasks
    class CopyServiceProxyTask
      include CallableTask
      include CopyTask

      def call
        copy_service.update_proxy source_service.show_proxy
        puts "updated proxy of #{copy_service.id} to match the original"
      end
    end
  end
end
