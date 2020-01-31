RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::Apply::ApplySubcommand do
  include_context :random_name

  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
    let(:svc_id) { 1 }
    let(:service_name) { 'some_name' }
    let(:service_attrs) { { 'id' => svc_id, 'name' => service_name } }
    let(:remote_name) { "myremote" }

    let(:options) { {} }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      allow(service).to receive(:attrs).and_return(service_attrs)
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
    end

    context "when the service is not found" do
      let(:arguments) { { remote: remote_name, service_id_or_system_name: svc_ref } }
      let(:svc_ref) { "unexistingservice" }
      let(:svc_params) { { "name" => svc_ref, "system_name" => svc_ref } }

      shared_examples "successfully creates the service with the specified parameter and options" do
        it do
          expect(service_class).to receive(:find).with(remote: remote, ref: svc_ref).and_return(nil)
          expect(service_class).to receive(:create).with(remote: remote, service_params: svc_params).and_return(service)
          expect { subject.run }.to output(/Applied Service id: #{svc_id}/).to_stdout
        end
      end

      include_examples "successfully creates the service with the specified parameter and options"

      context "when name in options" do
        let(:svc_name) { "adifferentname" }
        let(:options) { { name: svc_name } }
        let(:svc_params) { { "name" => svc_name, "system_name" => svc_ref } }
        include_examples "successfully creates the service with the specified parameter and options"
      end

      context "when deployment-mode in options" do
        let(:deployment_option) { "valid_deploymentoption" }
        let(:options) { { :'deployment-mode' => deployment_option } }
        let(:svc_params) { { "name" => svc_ref, "system_name" => svc_ref, "deployment_option" => deployment_option } }
        include_examples "successfully creates the service with the specified parameter and options"
      end

      context "when authentication-mode in options" do
        let(:backend_version) { "valid_backend_version" }
        let(:options) { { :'authentication-mode' => backend_version } }
        let(:svc_params) { { "name" => svc_ref, "system_name" => svc_ref, "backend_version" => backend_version } }
        include_examples "successfully creates the service with the specified parameter and options"
      end

      context "when description in options" do
        let(:description) { "adescription" }
        let(:options) { { :description => description } }
        let(:svc_params) { { "name" => svc_ref, "system_name" => svc_ref, "description" => description } }
        include_examples "successfully creates the service with the specified parameter and options"
      end

      context "when support-email in options" do
        let(:support_email) { "examplemail@gmail.com" }
        let(:options) { { :'support-email' => support_email } }
        let(:svc_params) { { "name" => svc_ref, "system_name" => svc_ref, "support_email" => support_email } }
        include_examples "successfully creates the service with the specified parameter and options"
      end
    end

    context "when the service already exists" do
      let(:svc_ref) { "existingservice" }
      let(:arguments) { { remote: remote_name, service_id_or_system_name: svc_ref } }

      before :example do
        expect(service_class).to receive(:find).with(remote: remote, ref: svc_ref).and_return(service)
      end

      context "with no options" do
        let(:options) { {} }
        it "the service is not updated" do
          expect { subject.run }.to output(/Applied Service id: #{svc_id}/).to_stdout
        end
      end

      context "with options" do
        let(:description) { "adescription" }
        let(:svc_name) { "aname" }
        let(:deployment_mode) { "adeploymentmode" }
        let(:options) { { description: description, name: svc_name, :'deployment-mode' => deployment_mode } }
        let(:svc_attrs) { { "description" => description, "name" => svc_name, "deployment_option" => deployment_mode } }
        it "the service is updated" do
          expect(service).to receive(:update).with(svc_attrs)
          expect { subject.run }.to output(/Applied Service id: #{svc_id}/).to_stdout
        end
      end
    end
  end
end
