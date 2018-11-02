require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::UpdateCommand::UpdateServiceSubcommand::ServiceUpdater do
  context '#target_service_params' do
    context 'with target system name' do
      subject do
        described_class.new(
          'https://provider_key_a@example.com',
          'source_service_id',
          'https://provider_key_a@example.com',
          'destination_service_id',
          'some_target_system_name',
          true
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
