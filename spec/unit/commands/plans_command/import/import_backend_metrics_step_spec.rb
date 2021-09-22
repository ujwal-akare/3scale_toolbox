RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Import::ImportBackendMetricsStep do
  let(:threescale_client) { instance_double(ThreeScale::API::Client, 'threescale_client') }
  let(:backend_class) { class_double(ThreeScaleToolbox::Entities::Backend).as_stubbed_const }
  let(:backend) { instance_double(ThreeScaleToolbox::Entities::Backend) }
  let(:metric_class) { class_double(ThreeScaleToolbox::Entities::BackendMetric).as_stubbed_const }
  let(:metric_01) { instance_double(ThreeScaleToolbox::Entities::BackendMetric) }
  let(:method_class) { class_double(ThreeScaleToolbox::Entities::BackendMethod).as_stubbed_const }
  let(:method_01) { instance_double(ThreeScaleToolbox::Entities::BackendMethod) }
  let(:backend_system_name) { 'backend01' }
  let(:backend_methods) { [] }
  let(:backend_metrics) { [] }
  let(:resource_methods) { [] }
  let(:resource_metrics) { [] }
  let(:artifacts_resource) do
    {
      'methods' => resource_methods,
      'metrics' => resource_metrics
    }
  end
  let(:context) do
    {
      threescale_client: threescale_client,
      artifacts_resource: artifacts_resource
    }
  end
  subject { described_class.new(context) }

  context '#call' do

    context 'no metric or methods' do
      it 'then no metrics or methods are created' do
        subject.call
      end
    end

    context do
      before :example do
        allow(backend_class).to receive(:find_by_system_name).with(remote: threescale_client, system_name: backend_system_name)
          .and_return(backend)
        allow(backend).to receive(:methods).and_return(backend_methods)
        allow(backend).to receive(:metrics).and_return(backend_metrics)
        allow(backend).to receive(:system_name).and_return(backend_system_name)
      end

      context 'with one missing metric' do
        let(:resource_metric_01) do
          { 'backend_system_name' => backend_system_name, 'system_name' => 'metric_01' }
        end
        let(:resource_metric_02) do
          { 'backend_system_name' => backend_system_name, 'system_name' => 'metric_02' }
        end
        let(:resource_metrics) { [resource_metric_01, resource_metric_02] }
        let(:backend_metrics) { [metric_01] }

        before :example do
          allow(metric_01).to receive(:system_name).and_return('metric_01')
        end

        it 'then one metric is created' do
          expect(metric_class).to receive(:create).with(hash_including(attrs: resource_metric_02))
          subject.call
        end
      end

      context 'with one missing method' do
        let(:resource_method_01) do
          { 'backend_system_name' => backend_system_name, 'system_name' => 'method_01' }
        end
        let(:resource_method_02) do
          { 'backend_system_name' => backend_system_name, 'system_name' => 'method_02' }
        end
        let(:resource_methods) { [resource_method_01, resource_method_02] }
        let(:backend_methods) { [method_01] }

        before :example do
          allow(method_01).to receive(:system_name).and_return('method_01')
        end

        it 'then one method is created' do
          expect(method_class).to receive(:create).with(hash_including(attrs: resource_method_02))
          subject.call
        end
      end
    end
  end
end
