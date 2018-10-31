require '3scale_toolbox'
require '3scale_toolbox/commands'

RSpec.describe ThreeScaleToolbox::Commands::CopyCommand::CopyServiceSubcommand do
  include_context :source_service_data

  context '#copy_service_params' do
    subject { described_class.new(nil, nil, nil) }

    it 'all expected params are copied' do
      new_service_params = subject.copy_service_params(source_service_obj, nil)

      expect(new_service_params).to include(*source_service_params)
    end

    it 'extra params are not copied' do
      extra_params = {
        'some_weird_param' => 'value0',
        'some_other_weird_param' => 'value1'
      }
      new_service_params = subject.copy_service_params(
        source_service_obj.merge(extra_params), nil
      )
      expect(new_service_params).to include(*source_service_params)
      expect(new_service_params).not_to include(*extra_params)
    end

    it 'missing params are not copied' do
      missing_params = %w[description backend_version]
      missing_params.each do |key|
        source_service_obj.delete(key)
      end
      new_service_params = subject.copy_service_params(source_service_obj, nil)
      expect(new_service_params).to include(*source_service_obj.keys)
      expect(new_service_params).not_to include(*missing_params)
    end
  end
end
