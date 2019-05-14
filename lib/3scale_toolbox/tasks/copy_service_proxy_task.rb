module ThreeScaleToolbox
  module Tasks
    class CopyServiceProxyTask
      include CopyTask

      def call
        target.update_proxy source.proxy
        puts "updated proxy of #{target.id} to match the original"
      end
    end
  end
end
