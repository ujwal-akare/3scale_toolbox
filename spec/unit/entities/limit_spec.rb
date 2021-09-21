RSpec.describe ThreeScaleToolbox::Entities::Limit do
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:plan) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
  let(:backend_class) { class_double(ThreeScaleToolbox::Entities::Backend).as_stubbed_const }
  let(:backend) { instance_double(ThreeScaleToolbox::Entities::Backend) }
  let(:backend_metric_0) { instance_double(ThreeScaleToolbox::Entities::BackendMetric, 'backend_metric_0') }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:metric_0) { instance_double(ThreeScaleToolbox::Entities::Metric, 'metric_0') }
  let(:metric_1) { instance_double(ThreeScaleToolbox::Entities::Metric, 'metric_1') }
  let(:method_0) { instance_double(ThreeScaleToolbox::Entities::Method, 'method_0') }
  let(:method_1) { instance_double(ThreeScaleToolbox::Entities::Method, 'method_1') }
  let(:backend_metric_0) { instance_double(ThreeScaleToolbox::Entities::BackendMetric, 'backend_metric_0') }
  let(:backend_metric_1) { instance_double(ThreeScaleToolbox::Entities::BackendMetric, 'backend_metric_1') }
  let(:backend_method_0) { instance_double(ThreeScaleToolbox::Entities::BackendMethod, 'backend_method_0') }
  let(:backend_method_1) { instance_double(ThreeScaleToolbox::Entities::BackendMethod, 'backend_method_1') }
  let(:plan_id) { 1 }
  let(:backend_id) { 3 }
  let(:metric_id) { 2 }

  before :each do
    allow(plan).to receive(:id).and_return(plan_id)
    allow(plan).to receive(:remote).and_return(remote)
    allow(plan).to receive(:service).and_return(service)
    allow(backend_class).to receive(:new).with(id: backend_id, remote: remote).and_return(backend)
    allow(backend).to receive(:system_name).and_return('backend_0')
  end

  context 'Limit.create' do
    let(:attrs) { { 'period' => 'eternity', 'value' => 0 } }
    subject { described_class.create(plan: plan, metric_id: metric_id, attrs: attrs) }

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:create_application_plan_limit).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when remote call succeeds' do
      let(:attrs) {  { 'period' => 'eternity' } }
      let(:limit_id) { 1 }
      let(:response) { { 'id' => limit_id, 'period' => 'eternity' } }

      before :each do
        expect(remote).to receive(:create_application_plan_limit).with(plan_id, metric_id, attrs).and_return(response)
      end

      it 'instance is returned' do
        expect(subject.id).to eq limit_id
      end
    end
  end

  context 'instance method' do
    let(:limit_id) { 999 }
    let(:metric_id) { 888 }
    let(:attrs) do
      {
        'period' => 'eternity',
        'value' => 1,
      }
    end
    let(:limit) { described_class.new(id: limit_id, plan: plan, metric_id: metric_id, attrs: attrs) }

    context '#metric_id' do
      subject { limit.metric_id }

      it 'returns metric_id' do
        is_expected.to eq metric_id
      end
    end

    context '#period' do
      subject { limit.period }

      it 'returns period' do
        is_expected.to eq 'eternity'
      end
    end

    context '#value' do
      subject { limit.value }

      it 'returns value' do
        is_expected.to eq 1
      end
    end

    context '#update' do
      let(:new_value) { 2 }
      let(:new_attrs) { { 'value' => new_value, 'unexpected_attrs': 3 } }
      subject { limit.update(new_attrs) }

      context 'when remote returns error' do
        before :each do
          expect(remote).to receive(:update_application_plan_limit).and_return('errors' => 'some error')
        end

        it 'ThreeScaleApiError is raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
        end
      end

      context 'when remote call succeeds' do
        let(:remote_response) do
          {
            'id' => limit_id,
            'value' => new_value,
            'period' => 'eternity',
          }
        end

        before :each do
          expect(remote).to receive(:update_application_plan_limit).with(plan_id, metric_id, limit_id, new_attrs).and_return(remote_response)
        end

        it 'new attrs returned' do
          is_expected.to eq(remote_response)
          expect(limit.value).to eq(new_value)
          expect(limit.period).to eq('eternity')
        end
      end
    end

    context '#delete' do
      subject { limit.delete }

      before :each do
        expect(remote).to receive(:delete_application_plan_limit).with(plan_id, metric_id, limit_id).and_return(true)
      end

      it 'remote call done' do
        is_expected.to be_truthy
      end
    end

    context '#to_cr' do
      let(:metrics) { [metric_0, metric_1] }

      subject { limit.to_cr }

      before :example do
        allow(plan).to receive(:service).and_return(service)
        allow(metric_0).to receive(:id).and_return(888)
        allow(metric_1).to receive(:id).and_return(777)
        allow(metric_0).to receive(:system_name).and_return('metric_0')
        allow(metric_1).to receive(:system_name).and_return('metric_1')
        allow(service).to receive(:metrics).and_return(metrics)
        allow(service).to receive(:methods).and_return([])
      end

      it 'period included' do
        expect(subject).to include('period' => 'eternity')
      end

      it 'value included' do
        expect(subject).to include('value' => 1)
      end

      it 'metricMethodRef included' do
        expect(subject).to include('metricMethodRef' => { 'systemName' => 'metric_0' })
      end

      context 'for backend metric' do
        let(:metric_id) { 666 }
        let(:attrs) do
          {
            'period' => 'eternity',
            'value' => 1,
            'links' => [
              {
                'rel' => 'metric',
                'href' => "https://example.com/admin/api/backend_apis/#{backend_id}/metrics/#{metric_id}"
              }
            ]
          }
        end

        before :example do
          allow(backend).to receive(:metrics).and_return([backend_metric_0])
          allow(backend_metric_0).to receive(:id).and_return(metric_id)
          allow(backend_metric_0).to receive(:system_name).and_return('backend_metric_0')
        end

        it 'metricMethodRef included backend' do
          expect(subject).to include('metricMethodRef' => { 'systemName' => 'backend_metric_0', 'backend' => 'backend_0' })
        end
      end
    end

    context '#product_metric' do
      let(:metrics) { [metric_0, metric_1] }
      subject { limit.product_metric }

      before :example do
        expect(service).to receive(:metrics).and_return(metrics)
      end

      it 'nil when metric_id not found' do
        expect(metric_0).to receive(:id).and_return(metric_id + 1)
        expect(metric_1).to receive(:id).and_return(metric_id + 2)
        is_expected.to be_nil
      end

      it 'returns metric when metric_id is found' do
        expect(metric_0).to receive(:id).and_return(metric_id + 1)
        expect(metric_1).to receive(:id).and_return(metric_id)
        is_expected.to be(metric_1)
      end
    end

    context '#product_method' do
      let(:methods) { [method_0, method_1] }
      subject { limit.product_method }

      before :example do
        expect(service).to receive(:methods).and_return(methods)
      end

      it 'nil when metric_id not found' do
        expect(method_0).to receive(:id).and_return(metric_id + 1)
        expect(method_1).to receive(:id).and_return(metric_id + 2)
        is_expected.to be_nil
      end

      it 'returns method when metric_id is found' do
        expect(method_0).to receive(:id).and_return(metric_id + 1)
        expect(method_1).to receive(:id).and_return(metric_id)
        is_expected.to be(method_1)
      end
    end

    context '#backend_metric' do
      let(:metrics) { [backend_metric_0, backend_metric_1] }
      let(:metric_id) { 333 }
      subject { limit.backend_metric }

      before :example do
        allow(backend).to receive(:metrics).and_return(metrics)
      end

      context 'when no backend link' do
        let(:attrs) { { 'period' => 'eternity', 'value' => 1 } }

        it do
          is_expected.to be_nil
        end
      end

      context 'when backend found' do
        let(:attrs) do
          {
            'period' => 'eternity',
            'value' => 1,
            'links' => [
              {
                'rel' => 'metric',
                'href' => "https://example.com/admin/api/backend_apis/#{backend_id}/metrics/#{metric_id}"
              }
            ]
          }
        end

        it 'nil when metric_id not found' do
          expect(backend_metric_0).to receive(:id).and_return(metric_id + 1)
          expect(backend_metric_1).to receive(:id).and_return(metric_id + 2)
          is_expected.to be_nil
        end

        it 'metric_id is found' do
          expect(backend_metric_0).to receive(:id).and_return(metric_id + 1)
          expect(backend_metric_1).to receive(:id).and_return(metric_id)
          is_expected.to be(backend_metric_1)
        end
      end
    end

    context '#backend_method' do
      let(:methods) { [backend_method_0, backend_method_1] }
      let(:metric_id) { 333 }
      subject { limit.backend_method }

      before :example do
        allow(backend).to receive(:methods).and_return(methods)
      end

      context 'when no backend link' do
        let(:attrs) { { 'period' => 'eternity', 'value' => 1 } }

        it do
          is_expected.to be_nil
        end
      end

      context 'when backend found' do
        let(:attrs) do
          {
            'period' => 'eternity',
            'value' => 1,
            'links' => [
              {
                'rel' => 'metric',
                'href' => "https://example.com/admin/api/backend_apis/#{backend_id}/metrics/#{metric_id}"
              }
            ]
          }
        end

        it 'nil when metric_id not found' do
          expect(backend_method_0).to receive(:id).and_return(metric_id + 1)
          expect(backend_method_1).to receive(:id).and_return(metric_id + 2)
          is_expected.to be_nil
        end

        it 'metric_id is found' do
          expect(backend_method_0).to receive(:id).and_return(metric_id + 1)
          expect(backend_method_1).to receive(:id).and_return(metric_id)
          is_expected.to be(backend_method_1)
        end
      end
    end

    context '#to_hash' do
      let(:metrics) { [] }
      let(:methods) { [] }
      let(:backend_metrics) { [] }
      let(:backend_methods) { [] }
      let(:attrs) do
        {
          'period' => 'eternity',
          'value' => 1,
          'metric_id' => metric_id,
          'links' => [
            {
              'rel' => 'metric',
              'href' => "https://example.com/admin/api/backend_apis/#{backend_id}/metrics/#{metric_id}"
            }
          ]
        }
      end
      subject { limit.to_hash }

      before :example do
        allow(service).to receive(:metrics).and_return(metrics)
        allow(service).to receive(:methods).and_return(methods)
        allow(backend).to receive(:metrics).and_return(backend_metrics)
        allow(backend).to receive(:methods).and_return(backend_methods)
        allow(metric_0).to receive(:id).and_return(0)
        allow(metric_0).to receive(:system_name).and_return('0')
        allow(metric_1).to receive(:id).and_return(1)
        allow(metric_1).to receive(:system_name).and_return('1')
        allow(method_0).to receive(:id).and_return(2)
        allow(method_0).to receive(:system_name).and_return('2')
        allow(method_1).to receive(:id).and_return(3)
        allow(method_1).to receive(:system_name).and_return('3')

        allow(backend_metric_0).to receive(:id).and_return(4)
        allow(backend_metric_0).to receive(:system_name).and_return('4')
        allow(backend_metric_0).to receive(:backend).and_return(backend)
        allow(backend_metric_1).to receive(:id).and_return(5)
        allow(backend_metric_1).to receive(:system_name).and_return('5')
        allow(backend_metric_1).to receive(:backend).and_return(backend)
        allow(backend_method_0).to receive(:id).and_return(6)
        allow(backend_method_0).to receive(:system_name).and_return('6')
        allow(backend_method_0).to receive(:backend).and_return(backend)
        allow(backend_method_1).to receive(:id).and_return(7)
        allow(backend_method_1).to receive(:system_name).and_return('7')
        allow(backend_method_1).to receive(:backend).and_return(backend)
      end

      context 'when product metric' do
        let(:metrics) { [metric_0, metric_1] }
        before :example do
          allow(metric_1).to receive(:id).and_return(metric_id)
        end

        it do
          is_expected.to eq({
            'period' => 'eternity',
            'value' => 1,
            'metric_system_name' => '1',
          })
        end
      end

      context 'when product method' do
        let(:methods) { [method_0, method_1] }
        before :example do
          allow(method_1).to receive(:id).and_return(metric_id)
        end

        it do
          is_expected.to eq({
            'period' => 'eternity',
            'value' => 1,
            'metric_system_name' => '3',
          })
        end
      end

      context 'when backend metric' do
        let(:backend_metrics) { [backend_metric_0, backend_metric_1] }
        before :example do
          allow(backend_metric_1).to receive(:id).and_return(metric_id)
        end

        it do
          is_expected.to eq({
            'period' => 'eternity',
            'value' => 1,
            'metric_system_name' => '5',
            'metric_backend_system_name' => 'backend_0',
          })
        end
      end

      context 'when backend method' do
        let(:backend_methods) { [backend_method_0, backend_method_1] }
        before :example do
          allow(backend_method_1).to receive(:id).and_return(metric_id)
        end

        it do
          is_expected.to eq({
            'period' => 'eternity',
            'value' => 1,
            'metric_system_name' => '7',
            'metric_backend_system_name' => 'backend_0',
          })
        end
      end

      context 'when metric not found' do
        it 'error is raised' do
          expect { subject }.to raise_error(ThreeScaleToolbox::Error, /referencing to metric id #{metric_id} which has not been found/)
        end
      end
    end
  end
end
