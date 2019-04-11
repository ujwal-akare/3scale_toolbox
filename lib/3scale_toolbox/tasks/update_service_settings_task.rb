module ThreeScaleToolbox
  module Tasks
    class UpdateServiceSettingsTask
      attr_reader :source, :target, :target_system_name

      def initialize(source:, target:, target_name:)
        @source = source
        @target = target
        @target_system_name = target_name
      end

      def call
        source_obj = source.show_service
        svc_obj = update_service target_service_params(source_obj)
        if (errors = svc_obj['errors'])
          raise ThreeScaleToolbox::Error, "Service has not been saved. Errors: #{errors}" \
        end

        puts "updated service settings for service id #{source.id}..."
      end

      private

      def update_service(service)
        svc_obj = target.update_service service

        # Source and target remotes might not allow same set of deployment options
        # Invalid deployment option check
        # use default deployment_option
        if (errors = svc_obj['errors']) &&
           ThreeScaleToolbox::Helper.service_invalid_deployment_option?(errors)
          service.delete('deployment_option')
          svc_obj = target.update_service(service)
        end

        svc_obj
      end

      # system name only included when specified from options
      def target_service_params(source)
        target_svc_obj = ThreeScaleToolbox::Helper.filter_params(Entities::Service::VALID_PARAMS, source)
        target_svc_obj.delete('system_name')
        target_svc_obj.tap do |hash|
          hash['system_name'] = target_system_name unless target_system_name.nil?
        end
      end
    end
  end
end
