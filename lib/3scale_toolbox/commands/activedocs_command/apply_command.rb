module ThreeScaleToolbox
  module Commands
    module ActiveDocsCommand
      module Apply
        class ApplySubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command
          include ThreeScaleToolbox::ResourceReader

          def self.command
            Cri::Command.define do
              name        'apply'
              usage       'apply <remote> <activedocs_id_or_system_name>'
              summary     'Update activedocs'
              description 'Create or update an ActiveDocs'
              runner ApplySubcommand

              param   :remote
              param   :activedocs_id_or_system_name

              option :i, :'service-id', "Specify the Service ID associated to the ActiveDocs", argument: :required
              option :p, :'publish', "Specify it to publish the ActiveDocs on the Developer Portal. Otherwise it will be hidden", argument: :forbidden
              option nil, :'hide', "Specify it to hide the ActiveDocs on the Developer Portal", argument: :forbidden
              option nil, :'skip-swagger-validations', "Skip validation of the Swagger specification. true or false", argument: :required, transform: ThreeScaleToolbox::Helper::BooleanTransformer.new
              option :d, :'description', "Specify the description of the ActiveDocs", argument: :required
              option :s, :'name', "Specify the name of the ActiveDocs", argument: :required
              option nil, :'openapi-spec', "Specify the swagger spec. Can be a file, an URL or '-' to read from stdin. This option is mandatory when applying the ActiveDoc for the first time", argument: :required
            end
          end

          def run
            res = activedocs
            validate_option_params
            if !res
              res = Entities::ActiveDocs::create(remote: remote, attrs: create_activedocs_attrs)
            else
              res.update(activedocs_attrs) unless activedocs_attrs.empty?
            end

            output_msg_array = ["Applied ActiveDocs id: #{res.id}"]
            output_msg_array << "Published" if option_publish
            output_msg_array << "Hidden" if option_hide
            puts output_msg_array.join(";")
          end

          private

          def remote
            @remote ||= threescale_client(arguments[:remote])
          end

          def validate_option_params
            if option_publish && option_hide
              raise ThreeScaleToolbox::Error.new("--publish and --hide are mutually exclusive")
            end
          end

          def check_openapi_spec_defined
            if !option_openapi_spec
              raise ThreeScaleToolbox::Error.new("--openapi-spec is mandatory when ActiveDocs is created")
            end
          end

          def activedocs
            @activedocs ||= find_activedocs
          end

          def ref
            arguments[:activedocs_id_or_system_name]
          end

          def find_activedocs
            Entities::ActiveDocs.find(remote: remote, ref: ref)
          end

          def option_publish
            options.fetch(:publish, false)
          end

          def option_hide
            options.fetch(:hide, false)
          end

          def option_openapi_spec
            options[:'openapi-spec']
          end

          def activedocs_json_spec
            @json_spec ||= read_activedocs_json_spec
          end

          def read_activedocs_json_spec
            activedoc_spec = option_openapi_spec
            activedoc_spec_content = load_resource(activedoc_spec)
            JSON.pretty_generate(activedoc_spec_content)
          end

          def activedocs_attrs
            activedocs_basic_attrs.tap do |params|
              params["body"] = activedocs_json_spec if !option_openapi_spec.nil?
              params["published"] = true if option_publish
              params["published"] = false if option_hide
            end
          end

          def activedocs_basic_attrs
            {
              "service_id" => options[:'service-id'],
              "skip_swagger_validations" => options[:'skip-swagger-validations'],
              "description" => options[:'description'],
              "system_name" => options[:'system-name'],
              "name" => options[:name],
            }.compact
          end

          def create_activedocs_attrs
            check_openapi_spec_defined
            activedocs_attrs.merge(
              "system_name" => ref,
              "name" => ref,
              "body" => activedocs_json_spec,
            ) { |_key, oldval, _newval| oldval } # receiver of the merge message has key priority
          end
        end
      end
    end
  end
end
