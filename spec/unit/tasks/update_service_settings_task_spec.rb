require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Tasks::UpdateServiceSettingsTask do
  context '#call' do
    let(:source) { double('source') }
    let(:target) { double('target') }
    let(:target_id) { 2 }
    let(:service_settings) do
      {
        'name' => 'some_name',
        'system_name' => 'old_system_name'
      }
    end
    let(:target_name) { 'new_name' }
    subject { described_class.new(source: source, target: target, target_name: target_name) }

    before :each do
      expect(source).to receive(:show_service).and_return(service_settings)
    end

    context 'remote respond with error' do
      it 'error raised' do
        expect(target).to receive(:update_service).and_return('errors' => 'some error')
        expect { subject.call }.to raise_error(ThreeScaleToolbox::Error, /not been saved/)
      end
    end

    context 'system_name not provided' do
      let(:target_name) { nil }
      let(:service_id) { '7' }
      let(:expected_svc_settings) { service_settings.reject { |k, _| k == 'system_name' } }

      it 'service settings does not contain system_name' do
        expect(source).to receive(:id).and_return(service_id)
        expect(target).to receive(:update_service).with(expected_svc_settings).and_return('errors' => nil)
        expect { subject.call }.to output(/updated service settings for service id #{service_id}/).to_stdout
      end
    end

    context 'system_name provided' do
      let(:service_id) { '7' }
      let(:expected_svc_settings) { service_settings.merge('system_name' => target_name) }

      it 'service settings contains new provided system_name' do
        expect(source).to receive(:id).and_return(service_id)
        expect(target).to receive(:update_service).with(expected_svc_settings).and_return('errors' => nil)
        expect { subject.call }.to output(/updated service settings for service id #{service_id}/).to_stdout
      end
    end
  end
end
