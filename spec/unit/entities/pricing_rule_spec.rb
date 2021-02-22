RSpec.describe ThreeScaleToolbox::Entities::PricingRule do
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:plan) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
  let(:plan_id) { 1 }
  let(:metric_id) { 2 }
  let(:attrs) { { 'cost_per_unit' => 1.0, 'min' => 0, 'max' => 100, 'metric_id' => metric_id } }

  before :each do
    allow(plan).to receive(:id).and_return(plan_id)
    allow(plan).to receive(:remote).and_return(remote)
  end

  context 'PricingRule.create' do
    subject { described_class.create(plan: plan, metric_id: metric_id, attrs: attrs) }

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:create_pricingrule).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when remote call succeeds' do
      let(:pr_id) { 1 }
      let(:response) { attrs.merge('id' => pr_id) }

      before :each do
        expect(remote).to receive(:create_pricingrule).with(plan_id, metric_id, attrs).and_return(response)
      end

      it 'instance is returned' do
        expect(subject.id).to eq pr_id
      end
    end
  end

  context 'instance method' do
    let(:pr_id) { 1 }

    subject { described_class.new(id: pr_id, plan: plan, metric_id: metric_id, attrs: attrs) }

    context '#metric_id' do
      it 'returns metric_id' do
        expect(subject.metric_id).to eq metric_id
      end
    end

    context '#cost_per_unit' do
      it 'returns cost_per_unit' do
        expect(subject.cost_per_unit).to eq attrs.fetch('cost_per_unit').to_f
      end
    end

    context '#min' do
      it 'returns min' do
        expect(subject.min).to eq attrs.fetch('min')
      end
    end

    context '#max' do
      it 'returns max' do
        expect(subject.max).to eq attrs.fetch('max')
      end
    end

    context '#delete' do
      before :each do
        expect(remote).to receive(:delete_application_plan_pricingrule).with(plan_id, metric_id, pr_id).and_return(true)
      end

      it 'remote call done' do
        expect(subject.delete).to be_truthy
      end
    end

    context '#to_cr' do
      let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
      let(:metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric, 'metric_0') }
      let(:metric_1) { instance_double(ThreeScaleToolbox::Entities::Metric, 'metric_1') }
      let(:metrics) { [metric_0, metric_1] }

      subject { described_class.new(id: pr_id, plan: plan, metric_id: metric_id, attrs: attrs).to_cr }

      before :example do
        allow(plan).to receive(:service).and_return(service)
        allow(metric_0).to receive(:id).and_return(2)
        allow(metric_1).to receive(:id).and_return(777)
        allow(metric_0).to receive(:system_name).and_return('metric_0')
        allow(metric_1).to receive(:system_name).and_return('metric_1')
        allow(service).to receive(:metrics).and_return(metrics)
        allow(service).to receive(:methods).and_return([])
      end

      it 'from included' do
        expect(subject).to include('from' => 0)
      end

      it 'to included' do
        expect(subject).to include('to' => 100)
      end

      it 'pricePerUnit included' do
        expect(subject).to include('pricePerUnit' => 1.0)
      end

      it 'metricMethodRef included' do
        expect(subject).to include('metricMethodRef' => { 'systemName' => 'metric_0' })
      end

      context 'for backend metric' do
        let(:backend_class) { class_double(ThreeScaleToolbox::Entities::Backend).as_stubbed_const }
        let(:backend) { instance_double(ThreeScaleToolbox::Entities::Backend) }
        let(:backend_metric_0) { instance_double(ThreeScaleToolbox::Entities::BackendMetric, 'backend_metric_0') }
        let(:metric_id) { 666 }
        let(:backend_id) { 3 }
        let(:attrs) do
         {
           'cost_per_unit' => 1.0, 'min' => 0, 'max' => 100,
           'links' => [
             'rel' => 'metric',
             'href' => "https://example.com/admin/api/backend_apis/#{backend_id}/metrics/#{metric_id}"
           ]
          }
        end

        before :example do
          allow(backend_class).to receive(:new).with(id: backend_id, remote: remote).and_return(backend)
          allow(backend).to receive(:metrics).and_return([backend_metric_0])
          allow(backend).to receive(:system_name).and_return('backend_0')
          allow(backend_metric_0).to receive(:id).and_return(metric_id)
          allow(backend_metric_0).to receive(:system_name).and_return('backend_metric_0')
        end

        it 'metricMethodRef included backend' do
          expect(subject).to include('metricMethodRef' => { 'systemName' => 'backend_metric_0', 'backend' => 'backend_0' })
        end
      end
    end
  end
end
