RSpec.describe ThreeScaleToolbox::Commands::CopyCommand::CopyServiceSubcommand do
  context '#run' do
    let(:source_service_id) { 100 }
    let(:target_service_id) { 200 }
    let(:source_system_name) { 'source_name' }
    let(:source_service_obj) { instance_double(ThreeScaleToolbox::Entities::Service, 'source_service') }
    let(:target_service_obj) { instance_double(ThreeScaleToolbox::Entities::Service, 'target_service') }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:source_remote) { instance_double(ThreeScale::API::Client, 'source_remote') }
    let(:target_remote) { instance_double(ThreeScale::API::Client, 'target_remote') }
    let(:arguments) { { 'source_service': source_system_name } }
    let(:options) { { 'source': 'mysource', 'destination': 'mydestination' } }
    let(:expected_create_params) { { 'system_name' => source_system_name } }

    subject { described_class.new(options, arguments, nil) }

    before :each do
      # Remote stub
      expect(subject).to receive(:threescale_client).with('mysource').and_return(source_remote)
      expect(subject).to receive(:threescale_client).with('mydestination').and_return(target_remote)
      expect(service_class).to receive(:find).with(remote: source_remote, ref: source_system_name)
                                             .and_return(source_service_obj)
      allow(source_service_obj).to receive(:attrs).and_return('id' => source_service_id,
                                                              'name' => source_system_name,
                                                              'system_name' => source_system_name)
    end

    context 'when source and target service are the same' do
      before :example do
        expect(service_class).to receive(:find).with(remote: target_remote, ref: source_system_name)
                                               .and_return(source_service_obj)
        expect(source_service_obj).to receive(:id).and_return(1)
      end

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /Source and destination services are the same/)
      end
    end

    context 'when target service exists' do
      before :example do
        expect(service_class).to receive(:find).with(remote: target_remote, ref: source_system_name)
                                               .and_return(target_service_obj)
        expect(target_service_obj).to receive(:id).and_return(target_service_id)
      end

      it 'all required tasks are run' do
        # Task stubs
        [
          ThreeScaleToolbox::Tasks::CopyServiceSettingsTask,
          ThreeScaleToolbox::Tasks::CopyServiceProxyTask,
          ThreeScaleToolbox::Tasks::CopyMethodsTask,
          ThreeScaleToolbox::Tasks::CopyMetricsTask,
          ThreeScaleToolbox::Tasks::CopyApplicationPlansTask,
          ThreeScaleToolbox::Tasks::CopyLimitsTask,
          ThreeScaleToolbox::Tasks::CopyPoliciesTask,
          ThreeScaleToolbox::Tasks::CopyPricingRulesTask,
          ThreeScaleToolbox::Tasks::CopyActiveDocsTask,
          ThreeScaleToolbox::Tasks::CopyMappingRulesTask,
          ThreeScaleToolbox::Tasks::BumpProxyVersionTask,
        ].each do |task_class|
          task = double(task_class.to_s)
          task_class_obj = class_double(task_class).as_stubbed_const
          expect(task_class_obj).to receive(:new).and_return(task)
          expect(task).to receive(:call)
        end

        # Run
        expect { subject.run }.to output.to_stdout
      end

      context 'when rules only option set' do
        let(:options) do
          { 'source': 'mysource', 'destination': 'mydestination', 'rules-only': true }
        end

        it 'only mapping rules tasks are run' do
          # Task stubs
          [
            ThreeScaleToolbox::Tasks::CopyMappingRulesTask,
            ThreeScaleToolbox::Tasks::BumpProxyVersionTask,
          ].each do |task_class|
            task = double(task_class.to_s)
            task_class_obj = class_double(task_class).as_stubbed_const
            expect(task_class_obj).to receive(:new).and_return(task)
            expect(task).to receive(:call)
          end

          # Run
          expect { subject.run }.to output.to_stdout
        end
      end

      context 'when force option set' do
        let(:options) do
          { 'source': 'mysource', 'destination': 'mydestination', force: true }
        end

        it 'mapping rules are jeleted' do
          # Task stubs
          [
            ThreeScaleToolbox::Tasks::CopyServiceSettingsTask,
            ThreeScaleToolbox::Tasks::CopyServiceProxyTask,
            ThreeScaleToolbox::Tasks::CopyMethodsTask,
            ThreeScaleToolbox::Tasks::CopyMetricsTask,
            ThreeScaleToolbox::Tasks::CopyApplicationPlansTask,
            ThreeScaleToolbox::Tasks::CopyLimitsTask,
            ThreeScaleToolbox::Tasks::CopyPoliciesTask,
            ThreeScaleToolbox::Tasks::CopyPricingRulesTask,
            ThreeScaleToolbox::Tasks::CopyActiveDocsTask,
            ThreeScaleToolbox::Tasks::DestroyMappingRulesTask,
            ThreeScaleToolbox::Tasks::CopyMappingRulesTask,
            ThreeScaleToolbox::Tasks::BumpProxyVersionTask,
          ].each do |task_class|
            task = double(task_class.to_s)
            task_class_obj = class_double(task_class).as_stubbed_const
            expect(task_class_obj).to receive(:new).and_return(task)
            expect(task).to receive(:call)
          end

          # Run
          expect { subject.run }.to output.to_stdout
        end
      end
    end

    context 'when target service does not exist' do
      let(:expected_create_attrs) do
        { 'system_name' => source_system_name, 'name' => source_system_name }
      end
      before :example do
        expect(service_class).to receive(:find).with(remote: target_remote, ref: source_system_name)
                                               .and_return(nil)
        expect(service_class).to receive(:create).with(remote: target_remote,
                                                       service_params: expected_create_attrs)
                                                 .and_return(target_service_obj)
        expect(target_service_obj).to receive(:id).and_return(target_service_id)
      end

      it 'all required tasks are run' do
        # Task stubs
        [
          ThreeScaleToolbox::Tasks::CopyServiceSettingsTask,
          ThreeScaleToolbox::Tasks::CopyServiceProxyTask,
          ThreeScaleToolbox::Tasks::CopyMethodsTask,
          ThreeScaleToolbox::Tasks::CopyMetricsTask,
          ThreeScaleToolbox::Tasks::CopyApplicationPlansTask,
          ThreeScaleToolbox::Tasks::CopyLimitsTask,
          ThreeScaleToolbox::Tasks::CopyPoliciesTask,
          ThreeScaleToolbox::Tasks::CopyPricingRulesTask,
          ThreeScaleToolbox::Tasks::CopyActiveDocsTask,
          ThreeScaleToolbox::Tasks::DestroyMappingRulesTask,
          ThreeScaleToolbox::Tasks::CopyMappingRulesTask,
          ThreeScaleToolbox::Tasks::BumpProxyVersionTask,
        ].each do |task_class|
          task = double(task_class.to_s)
          task_class_obj = class_double(task_class).as_stubbed_const
          expect(task_class_obj).to receive(:new).and_return(task)
          expect(task).to receive(:call)
        end

        # Run
        expect { subject.run }.to output.to_stdout
      end
    end
  end
end
