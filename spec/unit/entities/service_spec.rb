require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Entities::Service do
  include_context :random_name
  let(:remote) { double('remote') }

  context 'Service.create' do
    let(:system_name) { random_lowercase_name }
    let(:service) { { 'name' => random_lowercase_name } }
    let(:service_info) { { remote: remote, service: service, system_name: system_name } }
    let(:expected_svc) { { 'name' => service['name'], 'system_name' => system_name } }

    it 'throws error on remote error' do
      expect(remote).to receive(:create_service).with(expected_svc).and_return('errors' => true)
      expect do
        described_class.create(service_info)
      end.to raise_error(ThreeScaleToolbox::Error, /Service has not been saved/)
    end

    it 'service instance is returned' do
      expect(remote).to receive(:create_service).with(expected_svc).and_return('errors' => nil, 'id' => 'some_id')
      service_obj = described_class.create(service_info)
      expect(service_obj.id).to eq('some_id')
      expect(service_obj.remote).to be(remote)
    end
  end

  context 'instance method' do
    let(:id) { 774 }
    let(:hits_metric) { { 'id' => 1, 'system_name' => 'hits' } }
    let(:metrics) do
      [
        { 'id' => 10, 'system_name' => 'metric_10' },
        hits_metric,
        { 'id' => 20, 'system_name' => 'metric_20' }
      ]
    end
    subject { described_class.new(id: id, remote: remote) }

    context '#show_service' do
      it 'calls show_service method' do
        expect(remote).to receive(:show_service).with(id)
        subject.show_service
      end
    end

    context '#update_proxy' do
      let(:proxy) { { param: 'value' } }

      it 'calls update_proxy method' do
        expect(remote).to receive(:update_proxy).with(id, proxy)
        subject.update_proxy(proxy)
      end
    end

    context '#show_proxy' do
      it 'calls show_proxy method' do
        expect(remote).to receive(:show_proxy).with(id)
        subject.show_proxy
      end
    end

    context '#metrics' do
      it 'calls list_metrics method' do
        expect(remote).to receive(:list_metrics).with(id)
        subject.metrics
      end
    end

    context '#hits' do
      it 'raises error if metric not found' do
        expect(remote).to receive(:list_metrics).with(id).and_return([])
        expect { subject.hits }.to raise_error(ThreeScaleToolbox::Error, /missing hits metric/)
      end

      it 'return hits metric' do
        expect(remote).to receive(:list_metrics).with(id).and_return(metrics)
        expect(subject.hits).to be(hits_metric)
      end
    end

    context '#methods' do
      it 'calls list_methods method' do
        expect(remote).to receive(:list_metrics).with(id).and_return(metrics)
        expect(remote).to receive(:list_methods).with(id, hits_metric['id'])
        subject.methods
      end
    end

    context '#create_metric' do
      it 'calls create_metric method' do
        expect(remote).to receive(:create_metric).with(id, hits_metric)
        subject.create_metric(hits_metric)
      end
    end

    context '#create_method' do
      let(:some_method) { { 'id': 5 } }
      let(:parent_metric_id) { 43 }

      it 'calls create_method method' do
        expect(remote).to receive(:create_method).with(id, parent_metric_id, some_method)
        subject.create_method(parent_metric_id, some_method)
      end
    end

    context '#plans' do
      it 'calls list_service_application_plans method' do
        expect(remote).to receive(:list_service_application_plans).with(id)
        subject.plans
      end
    end

    context '#create_application_plan' do
      let(:plan) { { 'id': 3 } }

      it 'calls create_application_plan method' do
        expect(remote).to receive(:create_application_plan).with(id, plan)
        subject.create_application_plan(plan)
      end
    end

    context '#plan_limits' do
      let(:plan_id) { 3 }

      it 'calls list_application_plan_limits method' do
        expect(remote).to receive(:list_application_plan_limits).with(plan_id)
        subject.plan_limits(plan_id)
      end
    end

    context '#create_application_plan_limit' do
      let(:plan_id) { 3 }
      let(:metric_id) { 4 }
      let(:limit) do
        {
          'period' => 'year',
          'value' => 10_000
        }
      end

      it 'calls create_application_plan_limit method' do
        expect(remote).to receive(:create_application_plan_limit).with(plan_id, metric_id, limit)
        subject.create_application_plan_limit(plan_id, metric_id, limit)
      end
    end

    context '#mapping_rules' do
      it 'calls list_mapping_rules method' do
        expect(remote).to receive(:list_mapping_rules).with(id)
        subject.mapping_rules
      end
    end

    context '#delete_mapping_rule' do
      let(:rule_id) { 3 }
      it 'calls delete_mapping_rule method' do
        expect(remote).to receive(:delete_mapping_rule).with(id, rule_id)
        subject.delete_mapping_rule(rule_id)
      end
    end

    context '#create_mapping_rule' do
      let(:mapping_rule) { { 'id' => 5 } }
      it 'calls create_mapping_rule method' do
        expect(remote).to receive(:create_mapping_rule).with(id, mapping_rule)
        subject.create_mapping_rule(mapping_rule)
      end
    end

    context '#update_service' do
      let(:params) { { 'id' => 5 } }
      it 'calls update_service method' do
        expect(remote).to receive(:update_service).with(id, params)
        subject.update_service(params)
      end
    end

    context '#policies' do
      it 'calls show_policies method' do
        expect(remote).to receive(:show_policies).with(id)
        subject.policies
      end
    end

    context '#update_policies' do
      let(:params) { [] }
      it 'calls update_policies method' do
        expect(remote).to receive(:update_policies).with(id, params)
        subject.update_policies(params)
      end
    end
  end
end
