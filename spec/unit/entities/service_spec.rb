RSpec.describe ThreeScaleToolbox::Entities::Service do
  include_context :random_name
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:common_error_response) { { 'errors' => { 'comp' => 'error' } } }
  let(:positive_response) { { 'errors' => nil, 'id' => 'some_id' } }

  context 'Service.create' do
    let(:system_name) { random_lowercase_name }
    let(:deployment_option) { 'hosted' }
    let(:service) do
      {
        'name' => random_lowercase_name,
        'deployment_option' => deployment_option,
        'system_name' => system_name,
      }
    end
    let(:service_info) { { remote: remote, service_params: service } }
    let(:expected_svc) { { 'name' => service['name'], 'system_name' => system_name } }

    it 'throws error on remote error' do
      expect(remote).to receive(:create_service).and_return(common_error_response)
      expect do
        described_class.create(service_info)
      end.to raise_error(ThreeScaleToolbox::Error, /Service has not been created/)
    end

    context 'deployment mode invalid' do
      let(:invalid_deployment_error_response) do
        {
          'errors' => {
            'deployment_option' => ['is not included in the list']
          }
        }
      end

      it 'deployment config is removed' do
        expect(remote).to receive(:create_service).with(hash_including('deployment_option'))
                                                  .and_return(invalid_deployment_error_response)
        expect(remote).to receive(:create_service).with(hash_excluding('deployment_option'))
                                                  .and_return(positive_response)
        service_obj = described_class.create(service_info)
        expect(service_obj.id).to eq(positive_response['id'])
      end

      it 'throws error when second request returns error' do
        expect(remote).to receive(:create_service).with(hash_including('deployment_option'))
                                                  .and_return(invalid_deployment_error_response)
        expect(remote).to receive(:create_service).with(hash_excluding('deployment_option'))
                                                  .and_return(common_error_response)
        expect do
          described_class.create(service_info)
        end.to raise_error(ThreeScaleToolbox::Error, /Service has not been created/)
      end
    end

    it 'throws deployment option error' do
      expect(remote).to receive(:create_service).and_return(common_error_response)
      expect do
        described_class.create(service_info)
      end.to raise_error(ThreeScaleToolbox::Error, /Service has not been created/)
    end

    it 'service instance is returned' do
      expect(remote).to receive(:create_service).and_return(positive_response)
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
    let(:methods) do
      [
        { 'id' => 101, 'system_name' => 'method_101' },
        { 'id' => 201, 'system_name' => 'method_201' }
      ]
    end
    let(:proxy) { { 'id' => 201 } }

    subject { described_class.new(id: id, remote: remote) }

    context '#attrs' do
      it 'calls show_service method' do
        expect(remote).to receive(:show_service).with(id).and_return({})
        subject.attrs
      end
    end

    context '#update_proxy' do

      it 'calls update_proxy method' do
        expect(remote).to receive(:update_proxy).with(id, proxy).and_return(proxy)
        expect(subject.update_proxy(proxy)).to eq(proxy)
      end
    end

    context '#proxy' do
      it 'calls show_proxy method' do
        expect(remote).to receive(:show_proxy).with(id).and_return(proxy)
        expect(subject.proxy).to eq(proxy)
      end
    end

    context '#metrics' do
      it 'calls list_metrics method' do
        expect(remote).to receive(:list_metrics).with(id).and_return(metrics)
        expect(subject.metrics).to eq(metrics)
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
        expect(remote).to receive(:list_methods).with(id, hits_metric['id']).and_return(methods)
        expect(subject.methods(hits_metric['id'])).to eq(methods)
      end
    end

    context '#plans' do
      it 'calls list_service_application_plans method' do
        expect(remote).to receive(:list_service_application_plans).with(id)
        subject.plans
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

    context '#update' do
      let(:params) { { 'name' => 'new name' } }
      let(:new_params) { { 'id' => 5, 'name' => 'new_name' } }

      before :example do
        expect(remote).to receive(:update_service).with(id, params).and_return(new_params)
      end

      it 'calls update_service method' do
        expect(subject.update(params)).to eq(new_params)
      end

      it 'call to attrs returns new params' do
        subject.update(params)
        expect(subject.attrs).to eq(new_params)
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

    context '#activedocs' do
      let(:owned_activedocs0) do
        {
          'id' => 0, 'name' => 'ad_0', 'system_name' => 'ad_0', 'service_id' => id
        }
      end
      let(:owned_activedocs1) do
        {
          'id' => 1, 'name' => 'ad_1', 'system_name' => 'ad_1', 'service_id' => id
        }
      end
      let(:not_owned_activedocs) do
        {
          'id' => 2, 'name' => 'ad_2', 'system_name' => 'ad_2', 'service_id' => 'other'
        }
      end
      let(:activedocs) { [owned_activedocs0, owned_activedocs1, not_owned_activedocs] }

      it 'filters activedocs not owned by service' do
        expect(remote).to receive(:list_activedocs).and_return(activedocs)
        expect(subject.activedocs).to match_array([owned_activedocs0, owned_activedocs1])
      end
    end

    context 'oidc' do
      let(:oidc_configuration) do
        {
          standard_flow_enabled: false,
          implicit_flow_enabled: true,
          service_accounts_enabled: false,
          direct_access_grants_enabled: false
        }
      end

      context '#oidc' do
        it 'calls show_oidc method' do
          expect(remote).to receive(:show_oidc).with(id).and_return(oidc_configuration)
          expect(subject.oidc).to eq(oidc_configuration)
        end
      end

      context '#update_oidc' do
        it 'calls update_oidc method' do
          expect(remote).to receive(:update_oidc).with(id, oidc_configuration).and_return(oidc_configuration)
          expect(subject.update_oidc(oidc_configuration)).to eq(oidc_configuration)
        end
      end
    end
  end
end
