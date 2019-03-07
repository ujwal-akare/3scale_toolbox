require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::CopyCommand::CopyServiceSubcommand do
  context '#run' do
    let(:options) do
      {
        'source': 'https://source_key@source.example.com',
        'destination': 'https://destination_key@destination.example.com',
        'target_system_name': 'some_system_name'
      }
    end
    let(:arguments) { { 'service_id': 'some_service_id' } }
    let(:service_obj) { { 'some_key' => 'some_value' } }

    subject { described_class.new(options, arguments, nil) }

    it 'all required tasks are run' do
      # Remote stub
      remote = double('remote')
      expect(subject).to receive(:threescale_client).twice.and_return(remote)

      # Entities::Service instance stub
      service = instance_double('ThreeScaleToolbox::Entities::Service')
      expect(service).to receive(:show_service).and_return(service_obj)
      expect(service).to receive(:id).and_return('ome_service_id')

      # Entities::Service class stub
      service_class = class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const
      expect(service_class).to receive(:new).with(id: 'some_service_id', remote: remote).and_return(service)
      expect(service_class).to receive(:create).with(remote: remote, service: service_obj,
                                                     system_name: 'some_system_name').and_return(service)
      # Task stubs
      [
        ThreeScaleToolbox::Tasks::CopyServiceProxyTask,
        ThreeScaleToolbox::Tasks::CopyMethodsTask,
        ThreeScaleToolbox::Tasks::CopyMetricsTask,
        ThreeScaleToolbox::Tasks::CopyApplicationPlansTask,
        ThreeScaleToolbox::Tasks::CopyLimitsTask,
        ThreeScaleToolbox::Tasks::DestroyMappingRulesTask,
        ThreeScaleToolbox::Tasks::CopyMappingRulesTask,
        ThreeScaleToolbox::Tasks::CopyPoliciesTask
      ].each do |task_class|
        task = double(task_class.to_s)
        task_class_obj = class_double(task_class).as_stubbed_const
        expect(task_class_obj).to receive(:new).and_return(task)
        expect(task).to receive(:call)
      end

      # Run
      subject.run
    end
  end
end
