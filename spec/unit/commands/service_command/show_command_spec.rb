RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::Show::ShowSubcommand do
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
      let(:arguments) { {remote: remote_name, service_id_or_system_name: service_ref} }

      it 'an error is raised' do
        expect(service_class).to receive(:find).with(remote: remote, ref: service_ref).and_return(nil)
        expect do
          subject.run
        end.to raise_error(ThreeScaleToolbox::Error, /Service.*does not exist/)
      end
    end

    context "when a service exists" do
      let(:service_ref) { "1" }
      let(:existing_service) { {"id" => service_ref, "system_name" => "existingservice", "name" => "name1", "support_email" => ""} }
      let(:arguments) { {remote: "myremote", service_id_or_system_name: service_ref} }

      before :example do
        expect(service).to receive(:attrs).and_return(existing_service).at_least(:once)
        expect(service_class).to receive(:find).with(remote: remote, ref: service_ref).and_return(service)
      end

      it "shows the service fields" do
        regex_str = ".*" + existing_service.fetch("id") +
                    ".*" + existing_service.fetch("name") +
                    ".*" + existing_service.fetch("system_name")
        expect do
          subject.run
        end.to output(/#{regex_str}/).to_stdout
      end

      it "shows non defined fields as (empty)" do
        expect do
          subject.run
        end.to output(/.*(empty).*/).to_stdout
      end

      it "shows empty string fields as (empty)" do
        expect do
          subject.run
        end.to output(/.*\(empty\).*/).to_stdout
      end
    end
  end
end
