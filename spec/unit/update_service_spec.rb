require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::UpdateCommand::UpdateServiceSubcommand do
  RSpec.shared_examples 'check tasks' do
    it 'all required tasks are run' do
      # Remote stub
      remote = double('remote')
      expect(subject).to receive(:threescale_client).twice.and_return(remote)

      # Entities::Service instance stub
      service = instance_double('ThreeScaleToolbox::Entities::Service')

      # Entities::Service class stub
      service_class = class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const
      expect(service_class).to receive(:new).with(id: 'src_id',
                                                  remote: remote).and_return(service)
      expect(service_class).to receive(:new).with(id: 'dst_id',
                                                  remote: remote).and_return(service)
      # Task stubs
      tasks.each do |task_class|
        task = double(task_class.to_s)
        task_class_obj = class_double(task_class).as_stubbed_const
        expect(task_class_obj).to receive(:new).and_return(task)
        expect(task).to receive(:call)
      end

      # Run
      subject.run
    end
  end

  context '#run' do
    let(:source) { 'https://source_key@source.example.com' }
    let(:destination) { 'https://destination_key@destination.example.com' }
    let(:target_system_name) { 'some_system_name' }
    let(:arguments) { { 'src_service_id': 'src_id', 'dst_service_id': 'dst_id' } }
    subject { described_class.new(options, arguments, nil) }

    context 'rules-only and force mapping rules' do
      let(:options) do
        {
          'source': source,
          'destination': destination,
          'target_system_name': target_system_name,
          'force': true,
          'rules-only': true
        }
      end
      let(:tasks) do
        [
          ThreeScaleToolbox::Tasks::DestroyMappingRulesTask,
          ThreeScaleToolbox::Tasks::CopyMappingRulesTask
        ]
      end
      include_examples 'check tasks'
    end

    context 'rules-only and do not force mapping rules' do
      let(:options) do
        {
          'source': source,
          'destination': destination,
          'target_system_name': target_system_name,
          'force': false,
          'rules-only': true
        }
      end
      let(:tasks) do
        [
          ThreeScaleToolbox::Tasks::CopyMappingRulesTask
        ]
      end
      include_examples 'check tasks'
    end

    context 'not rules-only and force mapping rules' do
      let(:options) do
        {
          'source': source,
          'destination': destination,
          'target_system_name': target_system_name,
          'force': true,
          'rules-only': false
        }
      end
      let(:tasks) do
        [
          ThreeScaleToolbox::Tasks::UpdateServiceSettingsTask,
          ThreeScaleToolbox::Tasks::CopyServiceProxyTask,
          ThreeScaleToolbox::Tasks::CopyMethodsTask,
          ThreeScaleToolbox::Tasks::CopyMetricsTask,
          ThreeScaleToolbox::Tasks::CopyApplicationPlansTask,
          ThreeScaleToolbox::Tasks::CopyLimitsTask,
          ThreeScaleToolbox::Tasks::DestroyMappingRulesTask,
          ThreeScaleToolbox::Tasks::CopyMappingRulesTask,
          ThreeScaleToolbox::Tasks::CopyPoliciesTask
        ]
      end
      include_examples 'check tasks'
    end

    context 'not rules-only and do not force mapping rules' do
      let(:options) do
        {
          'source': source,
          'destination': destination,
          'target_system_name': target_system_name,
          'force': false,
          'rules-only': false
        }
      end
      let(:tasks) do
        [
          ThreeScaleToolbox::Tasks::UpdateServiceSettingsTask,
          ThreeScaleToolbox::Tasks::CopyServiceProxyTask,
          ThreeScaleToolbox::Tasks::CopyMethodsTask,
          ThreeScaleToolbox::Tasks::CopyMetricsTask,
          ThreeScaleToolbox::Tasks::CopyApplicationPlansTask,
          ThreeScaleToolbox::Tasks::CopyLimitsTask,
          ThreeScaleToolbox::Tasks::CopyMappingRulesTask,
          ThreeScaleToolbox::Tasks::CopyPoliciesTask
        ]
      end
      include_examples 'check tasks'
    end
  end
end
