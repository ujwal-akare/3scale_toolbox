RSpec.describe ThreeScaleToolbox::Commands::PoliciesCommand::ExportSubcommand do
  include_context :temp_dir

  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client) }
    let(:remote_name) { 'myremote' }
    let(:service_ref) { 1 }
    let(:arguments) { { remote: remote_name, service_ref: service_ref.to_s } }
    let(:output_file) {}
    let(:options) { { file: output_file } }
    let(:policy1) do
      {
        'name' => 'apicast',
        'version' => 'builtin',
        'configuration' => {},
        'enabled' => true
      }
    end
    let(:policy2) do
      {
        'name' => 'content_caching',
        'version' => 'builtin',
        'configuration' => {},
        'enabled' => true
      }
    end
    let(:policy_chain) { [policy1, policy2] }
    let(:svc_a_attrs) { { 'id' => service_ref } }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      expect(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
      expect(remote).to receive(:show_service).and_return(svc_a_attrs)
      expect(remote).to receive(:show_policies).and_return(policy_chain)
    end

    context 'when file selected' do
      let(:output_file) { tmp_dir.join('policies.yaml') }

      it 'content is written to the file' do
        subject.run
        expect(output_file.read.size).to be_positive
      end

      it 'exports product policy chain' do
        subject.run
        exported_policies = YAML.safe_load(output_file.read)
        expect(exported_policies).to include(policy1, policy2)
      end
    end
  end
end
