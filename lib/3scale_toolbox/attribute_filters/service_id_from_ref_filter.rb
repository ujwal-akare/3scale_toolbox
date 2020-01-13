module ThreeScaleToolbox
  module AttributeFilters
    class ServiceIDFilterFromServiceRef
      include AttributeFilter

      attr_reader :remote, :service_ref, :service_id_key

      def initialize(remote, service_ref, service_id_key)
        @remote = remote
        @service_ref = service_ref
        @service_id_key = service_id_key
      end

      def filter(enumerable)
        svc_id = find_service
        enumerable.select { |e| e.key?(service_id_key) && e[service_id_key].to_s == svc_id.to_s }
      end

      private

      def find_service
        svc_id = -1
        Entities::Service.find(remote: remote, ref: service_ref).tap do |svc|
          svc_id = svc.id if !svc.nil?
        end
        svc_id
      end
    end
  end
end