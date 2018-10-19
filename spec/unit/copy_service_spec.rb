require '3scale_toolbox/cli'

RSpec.describe ThreeScaleToolbox::Commands::CopyCommand::CopyServiceSubcommand do
  context '#run' do
    it 'with insecure flag' do
      expect(described_class).to receive(:copy_service).with('service_id',
                                                             'source_id',
                                                             'destination_id',
                                                             'target_system_name_id',
                                                             true)
      opts = {
        source: 'source_id',
        destination: 'destination_id',
        target_system_name: 'target_system_name_id',
        insecure: true
      }
      described_class.run(opts, ['service_id'])
    end

    it 'without insecure flag' do
      expect(described_class).to receive(:copy_service).with('service_id',
                                                             'source_id',
                                                             'destination_id',
                                                             'target_system_name_id',
                                                             false)
      opts = {
        source: 'source_id',
        destination: 'destination_id',
        target_system_name: 'target_system_name_id'
      }
      described_class.run(opts, ['service_id'])
    end
  end
end
