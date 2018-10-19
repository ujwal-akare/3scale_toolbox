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
                                                                    true).and_return(updater)
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
                                                                    false).and_return(updater)
      opts = {
        source: 'source_id',
        destination: 'destination_id'
      }
      described_class.run(opts, %w[source_service_id target_service_id])
    end
  end
end
