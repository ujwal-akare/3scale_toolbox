RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::Delete::DeleteSubcommand do
  include_context :random_name

  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
    let(:remote_name) { "myremote" }
    let(:options) {}

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
    end

    context "when the service does not exists" do
      let(:service_ref) { "unexistingservice" }
      let(:arguments) { { remote: remote_name, service_id_or_system_name: service_ref } }

      it 'an error is raised' do
        expect(service_class).to receive(:find).with(remote: remote, ref: service_ref).and_return(nil)
        expect do
          subject.run
        end.to raise_error(ThreeScaleToolbox::Error, /Service.*does not exist/)
      end
    end

    context "when a service exists" do
      let(:service_ref) { "existingservice" }
      let(:arguments) { { remote: remote_name, service_id_or_system_name: service_ref } }

      it 'is removed' do
        svc_id = "3"
        expect(service).to receive(:delete).and_return(true)
        expect(service).to receive(:id).and_return(svc_id)
        expect(service_class).to receive(:find).with(remote: remote, ref: service_ref).and_return(service)
        expect do
          subject.run
        end.to output(/.*Service with id: #{svc_id} deleted.*/).to_stdout
      end
    end
  end
end
