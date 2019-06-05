RSpec.describe ThreeScaleToolbox::Tasks::UpdateServiceSettingsTask do
  context '#call' do
    let(:source) { instance_double('ThreeScaleToolbox::Entities::Service', 'source') }
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:target_id) { 2 }
    let(:deployment_option) { 'hosted' }
    let(:service_settings) do
      {
        'name' => 'some_name',
        'system_name' => 'old_system_name',
        'deployment_option' => deployment_option
      }
    end
    let(:service_id) { '1000' }
    let(:common_error_response) { { 'errors' => { 'comp' => 'error' } } }
    let(:positive_response) { { 'errors' => nil, 'id' => 'some_id' } }
    let(:target_name) { 'new_name' }
    subject { described_class.new(source: source, target: target, target_name: target_name) }

    before :each do
      expect(source).to receive(:attrs).and_return(service_settings)
    end

    context 'remote respond with error' do
      it 'error raised' do
        expect(target).to receive(:update).and_return(common_error_response)
        expect { subject.call }.to raise_error(ThreeScaleToolbox::Error, /not been saved/)
      end
    end

    context 'deployment mode invalid' do
      let(:invalid_deployment_error_response) do
        {
          'errors' => {
            'deployment_option' => ['is not included in the list']
          }
        }
      end

      it 'deployment config is set to hosted' do
        expect(source).to receive(:id).and_return(service_id)
        expect(target).to receive(:update).with(hash_including('deployment_option'))
                                          .and_return(invalid_deployment_error_response)
        expect(target).to receive(:update).with(hash_excluding('deployment_option'))
                                          .and_return(positive_response)
        expect { subject.call }.to output(/updated service settings for service id #{service_id}/).to_stdout
      end

      it 'throws error when second request returns error' do
        expect(target).to receive(:update).with(hash_including('deployment_option'))
                                          .and_return(invalid_deployment_error_response)
        expect(target).to receive(:update).with(hash_excluding('deployment_option'))
                                          .and_return(common_error_response)
        expect { subject.call }.to raise_error(ThreeScaleToolbox::Error, /not been saved/)
      end
    end

    context 'system_name not provided' do
      let(:target_name) { nil }
      let(:expected_svc_settings) { service_settings.reject { |k, _| k == 'system_name' } }

      it 'service settings does not contain system_name' do
        expect(source).to receive(:id).and_return(service_id)
        expect(target).to receive(:update).with(expected_svc_settings).and_return('errors' => nil)
        expect { subject.call }.to output(/updated service settings for service id #{service_id}/).to_stdout
      end
    end

    context 'system_name provided' do
      let(:expected_svc_settings) { service_settings.merge('system_name' => target_name) }

      it 'service settings contains new provided system_name' do
        expect(source).to receive(:id).and_return(service_id)
        expect(target).to receive(:update).with(expected_svc_settings).and_return('errors' => nil)
        expect { subject.call }.to output(/updated service settings for service id #{service_id}/).to_stdout
      end
    end
  end
end
