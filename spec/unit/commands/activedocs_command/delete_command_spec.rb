require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::ActiveDocsCommand::Delete::DeleteSubcommand do
  include_context :random_name

  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
    let(:activedocs_class) { class_double(ThreeScaleToolbox::Entities::ActiveDocs).as_stubbed_const }
    let(:activedocs) { instance_double(ThreeScaleToolbox::Entities::ActiveDocs) }
    let(:remote_name) { "myremote" }
    let(:options) {}

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
    end

    context "when the activedocs does not exists" do
      let(:activedocs_ref) { "unexistingadocs" }
      let(:arguments) { {remote: remote_name, activedocs_id_or_system_name: activedocs_ref } }

      it 'an error is raised' do
        expect(activedocs_class).to receive(:find).with(remote: remote, ref: activedocs_ref).and_return(nil)
        expect do
          subject.run
        end.to raise_error(ThreeScaleToolbox::Error, /ActiveDocs.*does not exist/)
      end
    end

    context "when a activedocs exists" do
      let(:activedocs_ref) { "existingadocs" }
      let(:arguments) { {remote: remote_name, activedocs_id_or_system_name: activedocs_ref } }
      
      it 'is removed' do
        adocs_id = "3"
        expect(activedocs).to receive(:delete).and_return(true)
        expect(activedocs).to receive(:id).and_return(adocs_id)
        expect(activedocs_class).to receive(:find).with(remote: remote, ref: activedocs_ref).and_return(activedocs)
        expect do
          subject.run
        end.to output(/.*ActiveDocs with id: #{adocs_id} deleted.*/).to_stdout
      end
    end
  end
end