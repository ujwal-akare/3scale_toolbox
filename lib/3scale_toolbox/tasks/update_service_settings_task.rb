module ThreeScaleToolbox
  module Tasks
    class UpdateServiceSettingsTask
      attr_reader :source_service, :copy_service, :target_system_name

      def initialize(source_service:, copy_service:, target_name:)
        @source_service = source_service
        @copy_service = copy_service
        @target_system_name = target_name
      end

      def call
        puts "updating service settings for service id #{source_service.id}..."
        source_service_obj = source_service.show_service
        response = copy_service.update_service(target_service_params(source_service_obj))
        raise Error, "Service has not been saved. Errors: #{response['errors']}" unless response['errors'].nil?
      end

      private

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
