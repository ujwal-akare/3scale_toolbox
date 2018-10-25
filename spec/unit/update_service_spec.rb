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

RSpec.describe ThreeScaleToolbox::Commands::UpdateCommand::UpdateServiceSubcommand::ServiceUpdater do
  include_context :source_service_data

  subject do
    described_class.new(
      'https://provider_key_a@example.com',
      'source_service_id',
      'https://provider_key_a@example.com',
      'destination_service_id',
      true
    )
  end

  context '#target_service_params' do
    it 'all expected params are copied' do
      target_service_obj = subject.target_service_params(source_service_obj)
      expect(target_service_obj).to include(*source_service_params)
    end
    it 'extra params are not copied' do
      extra_params = {
        'some_weird_param' => 'value0',
        'some_other_weird_param' => 'value1'
      }
      target_service_obj = subject.target_service_params(
        source_service_obj.merge(extra_params)
      )
      expect(target_service_obj).to include(*source_service_params)
      expect(target_service_obj).not_to include(*extra_params)
    end
    it 'missing params are not copied' do
      missing_params = %w[description backend_version]
      missing_params.each do |key|
        source_service_obj.delete(key)
      end
      target_service_obj = subject.target_service_params(source_service_obj)
      expect(target_service_obj).to include(*source_service_obj.keys)
      expect(target_service_obj).not_to include(*missing_params)
    end
  end
end
