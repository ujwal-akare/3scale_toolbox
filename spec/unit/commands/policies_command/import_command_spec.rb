RSpec.describe ThreeScaleToolbox::Commands::PoliciesCommand::ImportSubcommand do
  include_context :temp_dir

  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client) }
    let(:remote_name) { 'myremote' }
    let(:service_ref) { 1 }
    let(:arguments) { { remote: remote_name, service_ref: service_ref.to_s } }
    let(:input_file) {}
    let(:options) { { file: input_file } }
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
    end

    context 'when file selected' do
      let(:input_file) { tmp_dir.join('policies.yaml').tap { |policies_file| policies_file.write(policy_chain.to_yaml) } }

      it 'imports product policy chain' do
        expect(remote).to receive(:update_policies).with(service_ref, hash_including('policies_config' => policy_chain))

        subject.run
      end
    end
  end
end
