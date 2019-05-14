module ThreeScaleToolbox
  module Commands
    module MethodsCommand
      module Apply
        class ApplySubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'apply'
              usage       'apply [opts] <remote> <service> <method>'
              summary     'Update method'
              description 'Update (create if it does not exist) method'

              option      :n, :name, 'Method name', argument: :required
              flag        nil, :disabled, 'Disables this method in all application plans'
              flag        nil, :enabled, 'Enables this method in all application plans'
              option      nil, :description, 'Method description', argument: :required
              param       :remote
              param       :service_ref
              param       :method_ref

              runner ApplySubcommand
            end
          end

          def run
            validate_option_params
            hits = service.hits
            method = Entities::Method.find(service: service, parent_id: hits.fetch('id'),
                                           ref: method_ref)
            if method.nil?
              method = Entities::Method.create(service: service, parent_id: hits.fetch('id'),
                                               attrs: create_method_attrs)
            else
              method.update(method_attrs) unless method_attrs.empty?
            end

            method.disable if option_disabled
            method.enable if option_enabled

            output_msg_array = ["Applied method id: #{method.id}"]
            output_msg_array << 'Disabled' if option_disabled
            output_msg_array << 'Enabled' if option_enabled
            puts output_msg_array.join('; ')
          end

          private

          def validate_option_params
            raise ThreeScaleToolbox::Error, '--disabled and --enabled are mutually exclusive' \
              if option_enabled && option_disabled
          end

          def create_method_attrs
            method_attrs.merge('system_name' => method_ref,
                               'friendly_name' => method_ref) { |_key, oldval, _newval| oldval }
          end

          def method_attrs
            {
              'friendly_name' => options[:name],
              'description' => options[:description]
            }.compact
          end

          def option_enabled
            !options[:enabled].nil?
          end

          def option_disabled
            !options[:disabled].nil?
          end

          def service
            @service ||= find_service
          end

          def find_service
            Entities::Service.find(remote: remote,
                                   ref: service_ref).tap do |svc|
              raise ThreeScaleToolbox::Error, "Service #{service_ref} does not exist" if svc.nil?
            end
          end

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def service_ref
            arguments[:service_ref]
          end

          def method_ref
            arguments[:method_ref]
          end
        end
      end
    end
  end
end
