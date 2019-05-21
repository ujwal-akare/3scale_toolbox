RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::Create::CreateSubcommand do
  include_context :random_name

  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
    let(:remote_name) { "myremote" }

    let(:options) { {} }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
    end

    # This should cover the case where the service already exists
    # or other errors that are returned by calls to the API
    context "when there is an error creating the service" do
      let(:arguments) { {remote: remote_name, service_name: "existingservice"} }
      let(:exists_error_response) { { 'errors' => { 'system_name' => ["has already been taken"] } } }
      let(:already_exists_api_error) { ThreeScaleToolbox::ThreeScaleApiError.new('Service has not been created', exists_error_response) }
      it 'an error is raised' do
        expect(service_class).to receive(:create).and_raise(already_exists_api_error)
        expect do
          subject.run
        end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Service has not been created/)
      end
    end

    context "service name parameter is specified" do
      let(:arguments) { {remote: remote_name, service_name: service_name} }
      let(:service_name) { "a_service_name" }
      let(:service_create_params) { {"name" => service_name} }
      let(:service_create_args) { {remote: remote, service_params: service_create_params } }
      let(:service_id) { "1" }
      shared_examples "successfully creates the service with it" do
        it do
          expect(service).to receive(:id).and_return(service_id)
          expect(service_class).to receive(:create).with(service_create_args).and_return(service)
          expect do
            subject.run
          end.to output(/Service '#{service_name}' has been created with ID: #{service_id}/).to_stdout
        end
      end

      include_examples "successfully creates the service with it"

      context "and additional options are specified" do
        context "specifying system_name option" do
          let(:system_name) { "a_system_name" }
          let(:options) { { :'system-name' => system_name } }
          let(:service_create_params) { {"name" => service_name, "system_name" => system_name } }
          let(:service_create_args) { {remote: remote, service_params: service_create_params } }
          include_examples "successfully creates the service with it"
        end

        context "specifying authentication-mode option" do
          let(:authentication_mode) { "1" }
          let(:options) { { :'authentication-mode' => authentication_mode } }
          let(:service_create_params) { {"name" => service_name, "backend_version" => authentication_mode } }
          let(:service_create_args) { {remote: remote, service_params: service_create_params } }
          include_examples "successfully creates the service with it"
        end

        context "specifying a valid deployment option" do
          let(:deployment_mode) { "valid_deploymentoption" }
          let(:options) { { :'deployment-mode' => deployment_mode } }
          let(:service_create_params) { {"name" => service_name, "deployment_option" => deployment_mode } }
          let(:service_create_args) { {remote: remote, service_params: service_create_params } }
          include_examples "successfully creates the service with it"
        end
      end
    end
  end
end
