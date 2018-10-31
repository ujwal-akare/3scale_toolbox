require '3scale_toolbox/cli'

RSpec.describe ThreeScaleToolbox::Commands::UpdateCommand::UpdateServiceSubcommand do
  context '#run' do
    it 'with insecure flag' do
      updater = double('Some Update')
      allow(updater).to receive(:copy_mapping_rules)
      allow(updater).to receive(:update_service)
      expect(described_class::ServiceUpdater).to receive(:new).with('source_id',
                                                                    'source_service_id',
                                                                    'destination_id',
                                                                    'target_service_id',
                                                                    true,
                                                                    nil).and_return(updater)
      opts = {
        source: 'source_id',
        destination: 'destination_id',
        insecure: true
      }
      described_class.run(opts, %w[source_service_id target_service_id])
    end

    it 'without insecure flag' do
      updater = double('Some Update')
      allow(updater).to receive(:copy_mapping_rules)
      allow(updater).to receive(:update_service)
      expect(described_class::ServiceUpdater).to receive(:new).with('source_id',
                                                                    'source_service_id',
                                                                    'destination_id',
                                                                    'target_service_id',
                                                                    false,
                                                                    nil).and_return(updater)
      opts = {
        source: 'source_id',
        destination: 'destination_id'
      }
      described_class.run(opts, %w[source_service_id target_service_id])
    end
  end
end

RSpec.describe ThreeScaleToolbox::Commands::UpdateCommand::UpdateServiceSubcommand::ServiceUpdater do
  context '#target_service_params' do
    context 'with target system name' do
      subject do
        described_class.new(
          'https://provider_key_a@example.com',
          'source_service_id',
          'https://provider_key_a@example.com',
          'destination_service_id',
          true,
          'some_target_system_name'
        )
      end
      let(:target_service_params) { source_service_params }
      include_examples 'target service params'
    end

    context 'without target system name' do
      subject do
        described_class.new(
          'https://provider_key_a@example.com',
          'source_service_id',
          'https://provider_key_a@example.com',
          'destination_service_id',
          true,
          nil
        )
      end
      let(:target_service_params) do
        source_service_params.reject { |k| k == 'system_name' }
      end
      include_examples 'target service params'
    end
  end
end
