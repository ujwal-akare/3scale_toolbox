module ThreeScaleToolbox
  module Tasks
    class CopyServiceSettingsTask
      include CopyTask
      PARAMS_FILTER = %w[system_name id links]

      def call
        svc_obj = update_service source_service_settings
        if (errors = svc_obj['errors'])
          raise ThreeScaleToolbox::Error, "Service has not been saved. Errors: #{errors}" \
        end

        puts "updated service settings for service id #{source.id}..."
      end

      private

      def source_service_settings
        source.attrs.reject { |k, _| PARAMS_FILTER.include? k }
      end

      def update_service(service_attrs)
        svc_obj = target.update service_attrs

        # Source and target remotes might not allow same set of deployment options
        # Invalid deployment option check
        # use default deployment_option
        if (errors = svc_obj['errors']) &&
           ThreeScaleToolbox::Helper.service_invalid_deployment_option?(errors)
          service_attrs.delete('deployment_option')
          svc_obj = target.update service_attrs
        end

        svc_obj
      end
    end
  end
end
