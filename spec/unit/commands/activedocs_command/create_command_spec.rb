require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::ActiveDocsCommand::Create::CreateSubcommand do
  include_context :random_name

  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:activedocs_class) { class_double(ThreeScaleToolbox::Entities::ActiveDocs).as_stubbed_const }
    let(:activedocs) { instance_double(ThreeScaleToolbox::Entities::ActiveDocs) }
    let(:activedocs_id) { 1 }
    let(:activedocs_name) { 'a_activedocs_name' }
    let(:activedocs_attrs) { { 'id' => activedocs_id, 'name' => activedocs_name } }
    let(:remote_name) { "myremote" }

    let(:options) { {} }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      allow(activedocs).to receive(:attrs).and_return(activedocs_attrs)
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
    end

    # This should cover the case where the activedocs already exists
    # or other errors that are returned by calls to the API
    context "when there is an error creating the activedocs" do
      let(:arguments) { { remote: remote_name, activedocs_name: "existingactivedocs", activedocs_spec: "-" } }
      let(:exists_error_response) { { 'errors' => { 'system_name' => ["has already been taken"] } } }
      let(:already_exists_api_error) { ThreeScaleToolbox::ThreeScaleApiError.new('ActiveDocs has not been created', exists_error_response) }
      it 'an error is raised' do
        expect(activedocs_class).to receive(:create).and_raise(already_exists_api_error)
        expect(STDIN).to receive(:read).and_return("{}")
        expect do
          subject.run
        end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /ActiveDocs has not been created/)
      end
    end

    context "activedocs name parameter and spec are specified" do
      let(:arguments) { { remote: remote_name, activedocs_name: activedocs_name, activedocs_spec: "-" } }
      let(:activedoc_body_str) do
        <<~YAML
          ---
          value1: "content1"
        YAML
      end
      let(:activedoc_body_pretty_json) do
        activedoc_body_content = YAML.safe_load(activedoc_body_str)
        JSON.pretty_generate(activedoc_body_content)
      end
      let(:activedocs_create_params) {
        { "name" => activedocs_name,
          "body" => activedoc_body_pretty_json }
      }
      let(:activedocs_create_args) { { remote: remote, attrs: activedocs_create_params } }

      shared_examples "successfully creates the activedocs with it" do
        it do
          expect(STDIN).to receive(:read).and_return(activedoc_body_str)
          expect(activedocs_class).to receive(:create).with(activedocs_create_args).and_return(activedocs)
          expect do
            subject.run
          end.to output(/ActiveDocs '#{activedocs_name}' has been created with ID: #{activedocs_id}/).to_stdout
        end
      end

      include_examples "successfully creates the activedocs with it"

      context "and additional options are specified" do
        context "specifying system_name option" do
          let(:system_name) { "a_system_name" }
          let(:options) { { :'system-name' => system_name } }
          let(:activedocs_create_params) { { "name" => activedocs_name, "body" => activedoc_body_pretty_json, "system_name" => system_name } }
          include_examples "successfully creates the activedocs with it"
        end

        context "specifying description option" do
          let(:description) { "adescription" }
          let(:options) { { :description => description } }
          let(:activedocs_create_params) { { "name" => activedocs_name, "body" => activedoc_body_pretty_json, "description" => description } }
          include_examples "successfully creates the activedocs with it"
        end

        context "specifying a service id" do
          let(:service_id) { "aserviceid" }
          let(:options) { { :'service-id' => service_id } }
          let(:activedocs_create_params) { { "name" => activedocs_name, "body" => activedoc_body_pretty_json, "service_id" => service_id } }
          include_examples "successfully creates the activedocs with it"
        end

        context "specifying a published flag" do
          let(:published) { true }
          let(:options) { { :published => published } }
          let(:activedocs_create_params) { { "name" => activedocs_name, "body" => activedoc_body_pretty_json, "published" => published } }
          include_examples "successfully creates the activedocs with it"
        end

        context "specifying a skip-swagger-validations flag" do
          let(:skip_swagger_validation) { true }
          let(:options) { { :'skip-swagger-validations' => skip_swagger_validation } }
          let(:activedocs_create_params) { { "name" => activedocs_name, "body" => activedoc_body_pretty_json, "skip_swagger_validations" => skip_swagger_validation } }
          include_examples "successfully creates the activedocs with it"
        end
      end
    end
  end
end
