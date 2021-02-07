RSpec.describe ThreeScaleToolbox::Commands::PlansCommand::Import::ImportMetricsStep do
  let(:threescale_client) { instance_double('ThreeScale::API::Client', 'threescale_client') }
  let(:service_system_name) { 'myservice' }
  let(:service_class) { class_double('ThreeScaleToolbox::Entities::Service').as_stubbed_const }
  let(:service_info) { { remote: threescale_client, ref: service_system_name } }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:metric_class) { class_double('ThreeScaleToolbox::Entities::Metric').as_stubbed_const }
  let(:metric) { instance_double('ThreeScaleToolbox::Entities::Metric') }
  let(:method_class) { class_double('ThreeScaleToolbox::Entities::Method').as_stubbed_const }
  let(:method) { instance_double('ThreeScaleToolbox::Entities::Method') }
  let(:plan_system_name) { 'myplan' }
  let(:service_methods) { [] }
  let(:service_metrics) { [] }
  let(:resource_methods) { [] }
  let(:resource_metrics) { [] }
  let(:hits_metric) { { 'id' => 1 } }
  let(:artifacts_resource) do
    {
      'methods' => resource_methods,
      'metrics' => resource_metrics
    }
  end
  let(:context) do
    {
      threescale_client: threescale_client,
      service_system_name: service_system_name,
      plan_system_name: plan_system_name,
      artifacts_resource: artifacts_resource
    }
  end
  subject { described_class.new(context) }

  context '#call' do
    before :example do
      expect(service_class).to receive(:find).with(hash_including(service_info))
                                             .and_return(service)
      allow(service).to receive(:methods).and_return(service_methods)
      allow(service).to receive(:metrics).and_return(service_metrics)
      allow(service).to receive(:hits).and_return(hits_metric)
    end

    context 'no missing metric or methods' do
      it 'then no metrics or methods are created' do
        expect { subject.call }.not_to output.to_stdout
      end
    end

    context 'with missing metric' do
      let(:resource_metric) { { 'system_name' => 'metric01' } }
      let(:resource_metrics) { [resource_metric] }

      it 'then metric is created' do
        expect(metric_class).to receive(:create).with(hash_including(attrs: resource_metric))
                                                .and_return(metric)
        expect(metric).to receive(:attrs).and_return(resource_metric)
        expect { subject.call }.to output(/Created metric/).to_stdout
      end
    end

    context 'with missing method' do
      let(:resource_method) { { 'system_name' => 'method_01' } }
      let(:resource_methods) { [resource_method] }
      let(:hits_id) { 9999 }
      let(:hits_metric) { { 'id' => hits_id, 'system_name' => 'hits' } }
      let(:service_metrics) { [hits_metric] }

      it 'then method is created' do
        expect(method_class).to receive(:create).with(hash_including(attrs: resource_method))
                                                .and_return(method)
        expect(method).to receive(:attrs).and_return(resource_method)
        expect { subject.call }.to output(/Created method/).to_stdout
      end
    end
  end
end
