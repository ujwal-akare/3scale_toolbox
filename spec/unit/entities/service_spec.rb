RSpec.describe ThreeScaleToolbox::Entities::Service do
  include_context :random_name
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:common_error_response) { { 'errors' => { 'comp' => 'error' } } }
  let(:positive_response) { { 'errors' => nil, 'id' => 1000 } }

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
        described_class.create(**service_info)
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
        service_obj = described_class.create(**service_info)
        expect(service_obj.id).to eq(positive_response['id'])
      end

      it 'throws error when second request returns error' do
        expect(remote).to receive(:create_service).with(hash_including('deployment_option'))
                                                  .and_return(invalid_deployment_error_response)
        expect(remote).to receive(:create_service).with(hash_excluding('deployment_option'))
                                                  .and_return(common_error_response)
        expect do
          described_class.create(**service_info)
        end.to raise_error(ThreeScaleToolbox::Error, /Service has not been created/)
      end
    end

    it 'throws deployment option error' do
      expect(remote).to receive(:create_service).and_return(common_error_response)
      expect do
        described_class.create(**service_info)
      end.to raise_error(ThreeScaleToolbox::Error, /Service has not been created/)
    end

    it 'service instance is returned' do
      expect(remote).to receive(:create_service).and_return(positive_response)
      service_obj = described_class.create(**service_info)
      expect(service_obj.id).to eq(1000)
      expect(service_obj.remote).to be(remote)
    end
  end

  context 'Service.find' do
    let(:system_name) { random_lowercase_name }
    let(:service_id) { 10001 }
    let(:service_info) { { remote: remote, ref: system_name } }

    it 'remote call raises unexpected error' do
      expect(remote).to receive(:list_services).and_raise(StandardError)
      expect do
        described_class.find(**service_info)
      end.to raise_error(StandardError)
    end

    it 'returns nil when the service does not exist' do
      expect(remote).to receive(:list_services).and_return([{ "system_name" => "sysname1" }, { "system_name" => "sysname2" }])
      expect(described_class.find(**service_info)).to be_nil
    end

    it 'service instance is returned when specifying an existing service ID' do
      expect(remote).to receive(:show_service).and_return({ "id" => service_id, "system_name" => "sysname1" })
      service_obj = described_class.find(remote: remote, ref: service_id)
      expect(service_obj.id).to eq(service_id)
      expect(service_obj.remote).to be(remote)
    end

    it 'service instance is returned when specifying an existing system-name' do
      expect(remote).to receive(:list_services).and_return([{ "id" => 3, "system_name" => system_name }, { "id" => 7, "system_name" => "sysname1" }])
      service_obj = described_class.find(**service_info)
      expect(service_obj).to be
      expect(service_obj.id).to eq(3)
      expect(service_obj.remote).to be(remote)
    end

    it 'service instance is returned from service ID in front of an existing service with the same system-name as the ID' do
      svc_info = { remote: remote, ref: 3 }
      expect(remote).to receive(:show_service).and_return("id" => svc_info[:ref], "system_name" => "sysname1")
      allow(remote).to receive(:list_services).and_return([{ "id" => 4, "system_name" => svc_info[:ref] }, { 'id' => 5, "system_name" => "sysname2" }])
      service_obj = described_class.find(**svc_info)
      expect(service_obj.id).to eq(svc_info[:ref])
      expect(service_obj.remote).to be(remote)
    end
  end

  context 'Service.find_by_system_name' do
    let(:system_name) { random_lowercase_name }
    let(:service_info) { { remote: remote, system_name: system_name } }

    it 'an exception is raised when remote is not configured' do
      expect(remote).to receive(:list_services).and_raise(StandardError)
      expect do
        described_class.find_by_system_name(**service_info)
      end.to raise_error(StandardError)
    end

    it 'returns nil when the service does not exist' do
      expect(remote).to receive(:list_services).and_return([{ "system_name" => "sysname1" }, { "system_name" => "sysname2" }])
      expect(described_class.find_by_system_name(**service_info)).to be_nil
    end

    it 'service instance is returned when specifying an existing system-name' do
      expect(remote).to receive(:list_services).and_return([{ "id" => 3, "system_name" => system_name }, { "id" => 7, "system_name" => "sysname1" }])
      service_obj = described_class.find_by_system_name(**service_info)
      expect(service_obj.id).to eq(3)
      expect(service_obj.remote).to be(remote)
    end

    context 'when remote returns error' do
      before :each do
        expect(remote).to receive(:list_services).and_return('errors' => 'some error')
      end

      it 'ThreeScaleApiError is raised' do
        expect { described_class.find_by_system_name(**service_info) }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError)
      end
    end

    context 'when service list length is' do
      subject { described_class.find_by_system_name(remote: remote, system_name: system_name) }
      let(:expected_service_id) { 0 }

      context 'MAX_SERVICES_PER_PAGE - 1' do
        let(:service_response) do
          # the latest service is the one with the searched system_name
          (1..ThreeScale::API::MAX_SERVICES_PER_PAGE - 2).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end + [{ 'id' => expected_service_id, 'system_name' => system_name }]
        end

        it 'then 1 remote call' do
          expect(remote).to receive(:list_services).with(page: 1, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response)

          expect(subject.id).to eq expected_service_id
        end
      end

      context 'MAX_SERVICES_PER_PAGE' do
        let(:service_response01) do
          # the latest service is the one with the searched system_name
          (1..ThreeScale::API::MAX_SERVICES_PER_PAGE - 1).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end + [{ 'id' => expected_service_id, 'system_name' => system_name }]
        end
        let(:service_response02) { [] }

        it 'then 2 remote call' do
            expect(remote).to receive(:list_services).with(page: 1, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response01)
            expect(remote).to receive(:list_services).with(page: 2, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response02)

            expect(subject.id).to eq expected_service_id
        end
      end

      context 'MAX_SERVICES_PER_PAGE + 1' do
        let(:service_response01) do
          (1..ThreeScale::API::MAX_SERVICES_PER_PAGE).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end
        end
        # the latest service is the one with the searched system_name
        let(:service_response02) { [{ 'id' => expected_service_id, 'system_name' => system_name }] }

        it 'then 2 remote call' do
            expect(remote).to receive(:list_services).with(page: 1, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response01)
            expect(remote).to receive(:list_services).with(page: 2, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response02)

            expect(subject.id).to eq expected_service_id
        end
      end

      context '2 * MAX_SERVICES_PER_PAGE' do
        let(:service_response01) do
          (1..ThreeScale::API::MAX_SERVICES_PER_PAGE).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end
        end
        let(:service_response02) do
          # the latest service is the one with the searched system_name
          (1..ThreeScale::API::MAX_SERVICES_PER_PAGE - 1).map do |idx|
            { 'id' => ThreeScale::API::MAX_SERVICES_PER_PAGE + idx, 'system_name' => (ThreeScale::API::MAX_SERVICES_PER_PAGE + idx).to_s }
          end + [{ 'id' => expected_service_id, 'system_name' => system_name }]
        end
        let(:service_response03) { [] }

        it 'then 3 remote call' do
            expect(remote).to receive(:list_services).with(page: 1, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response01)
            expect(remote).to receive(:list_services).with(page: 2, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response02)
            expect(remote).to receive(:list_services).with(page: 3, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response03)

            expect(subject.id).to eq expected_service_id
        end
      end

      context '2 * MAX_SERVICES_PER_PAGE + 1' do
        let(:service_response01) do
          (1..ThreeScale::API::MAX_SERVICES_PER_PAGE).map do |idx|
            { 'id' => idx, 'system_name' => idx.to_s }
          end
        end
        let(:service_response02) do
          # the latest service is the one with the searched system_name
          (1..ThreeScale::API::MAX_SERVICES_PER_PAGE).map do |idx|
            { 'id' => ThreeScale::API::MAX_SERVICES_PER_PAGE + idx, 'system_name' => (ThreeScale::API::MAX_SERVICES_PER_PAGE + idx).to_s }
          end
        end
        let(:service_response03) { [{ 'id' => expected_service_id, 'system_name' => system_name }] }

        it 'then 3 remote call' do
            expect(remote).to receive(:list_services).with(page: 1, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response01)
            expect(remote).to receive(:list_services).with(page: 2, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response02)
            expect(remote).to receive(:list_services).with(page: 3, per_page: ThreeScale::API::MAX_SERVICES_PER_PAGE).and_return(service_response03)

            expect(subject.id).to eq expected_service_id
        end
      end
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
      it 'returns only metrics' do
        expect(remote).to receive(:list_metrics).with(id).and_return(metrics + methods)
        expect(remote).to receive(:list_methods).with(id, 1).and_return(methods)
        expect(subject.metrics).to eq(metrics)
      end
    end

    context '#hits' do
      it 'raises error if metric not found' do
        expect(remote).to receive(:list_metrics).with(id).and_return([])
        expect { subject.hits }.to raise_error(ThreeScaleToolbox::Error, /missing hits metric/)
      end

      it 'return hits metric' do
        expect(remote).to receive(:list_metrics).with(id).and_return(metrics + methods)
        expect(subject.hits).to be(hits_metric)
      end
    end

    context '#methods' do
      it 'calls list_methods method' do
        expect(remote).to receive(:list_methods).with(id, hits_metric['id']).and_return(methods)
        expect(subject.methods(hits_metric['id'])).to eq(methods)
      end
    end

    context '#metrics_and_methods' do
      it 'calls list_metrics method' do
        expect(remote).to receive(:list_metrics).with(id).and_return(metrics + methods)
        expect(subject.metrics_and_methods).to eq(metrics + methods)
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

      context 'remote call successfull' do
        before :example do
          expect(remote).to receive(:update_service).with(id, params).and_return(new_params)
        end

        it 'returns new params' do
          expect(subject.update(params)).to eq(new_params)
        end

        it 'attrs method returns new params' do
          subject.update(params)
          expect(subject.attrs).to eq(new_params)
        end
      end

      context 'new attrs include invalid deployment option' do
        let(:params) { { 'name' => 'new name', 'deployment_option' => 'self_managed' } }
        let(:invalid_deployment_mode_error) do
          {
            'errors' => {
              'deployment_option' => ['is not included in the list']
            }
          }
        end

        before :example do
          expect(remote).to receive(:update_service).with(id, params)
                                                    .and_return(invalid_deployment_mode_error)
        end

        it 'second update call with deployment mode attr removed' do
          sanitized_params = params.dup.tap { |hs| hs.delete('deployment_option') }
          expect(remote).to receive(:update_service).with(id, sanitized_params)
                                                    .and_return(new_params)
          expect(subject.update(params)).to eq(new_params)
        end
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

    context '#proxy_configs' do
      it 'returns an error on remote error' do
        expect(remote).to receive(:proxy_config_list).and_return(common_error_response)
        expect { subject.proxy_configs("sandbox") }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /ProxyConfigs not read/)
      end

      it 'returns an empty array when there are no proxy_configs in an environment' do
        expect(remote).to receive(:proxy_config_list).with(id, "sandbox").and_return([])
        results = subject.proxy_configs("sandbox")
        expect(results.size).to eq(0)
      end

      context "when sandbox environment is requested" do
        let(:owned_proxy_config_sandbox_0) { { "id" => 3, "environment" => "sandbox", "version" => 0} }
        let(:owned_proxy_config_sandbox_1) { { "id" => 4, "environment" => "sandbox", "version" => 1} }
        let(:environment) { "sandbox" }

        it 'returns the expected ProxyConfig entities' do
          expect(remote).to receive(:proxy_config_list).with(id, environment).and_return([owned_proxy_config_sandbox_0, owned_proxy_config_sandbox_1])
          results = subject.proxy_configs(environment)
          expect(results.size).to eq(2)
          pc_0 = results[0]
          pc_1 = results[1]
          expect(pc_0).to be_a(ThreeScaleToolbox::Entities::ProxyConfig)
          expect(pc_1).to be_a(ThreeScaleToolbox::Entities::ProxyConfig)
          expect(pc_0.attrs['id']).to eq(3)
          expect(pc_0.attrs['environment']).to eq(environment)
          expect(pc_0.attrs['version']).to eq(0)
          expect(pc_1.attrs['id']).to eq(4)
          expect(pc_1.attrs['environment']).to eq(environment)
          expect(pc_1.attrs['version']).to eq(1)
        end
      end

      context "when production environment is requested" do
        let(:owned_proxy_config_production_0) { { "id" => 0, "environment" => "production", "version" => 0} }
        let(:owned_proxy_config_production_1) { { "id" => 1, "environment" => "production", "version" => 1} }
        let(:environment) { "production" }
        it 'returns the expected ProxyConfig entities' do
          expect(remote).to receive(:proxy_config_list).with(id, environment).and_return([owned_proxy_config_production_0, owned_proxy_config_production_1])
          results = subject.proxy_configs(environment)
          expect(results.size).to eq(2)
          pc_0 = results[0]
          pc_1 = results[1]
          expect(pc_0).to be_a(ThreeScaleToolbox::Entities::ProxyConfig)
          expect(pc_1).to be_a(ThreeScaleToolbox::Entities::ProxyConfig)
          expect(pc_0.attrs['id']).to eq(0)
          expect(pc_0.attrs['environment']).to eq(environment)
          expect(pc_0.attrs['version']).to eq(0)
          expect(pc_1.attrs['id']).to eq(1)
          expect(pc_1.attrs['environment']).to eq(environment)
          expect(pc_1.attrs['version']).to eq(1)
        end
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

      context '#applications' do
        context 'list_applications returns error' do
          let(:request_error) { { 'errors' => 'some error' } }

          before :example do
            expect(remote).to receive(:list_applications).with(service_id: id)
                                                         .and_return(request_error)
          end

          it 'error is raised' do
            expect { subject.applications }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError,
                                                           /Service applications not read/)
          end
        end

        context 'list_applications returns applications' do
          let(:app01_attrs) { { 'id' => 1, 'name' => 'app01' } }
          let(:app02_attrs) { { 'id' => 2, 'name' => 'app02' } }
          let(:app03_attrs) { { 'id' => 3, 'name' => 'app03' } }
          let(:applications) { [app01_attrs, app02_attrs, app03_attrs] }

          before :example do
            expect(remote).to receive(:list_applications).with(service_id: id)
                                                         .and_return(applications)
          end

          it 'app01 is returned' do
            apps = subject.applications
            expect(apps.map(&:id)).to include(1)
          end

          it 'app02 is returned' do
            apps = subject.applications
            expect(apps.map(&:id)).to include(2)
          end

          it 'app03 is returned' do
            apps = subject.applications
            expect(apps.map(&:id)).to include(3)
          end
        end
      end

      context 'equality method' do
        let(:svc1) { described_class.new(id: id1, remote: remote1) }
        let(:svc2) { described_class.new(id: id2, remote: remote2) }
        let(:remote1) { instance_double(ThreeScale::API::Client, 'remote1') }
        let(:remote2) { instance_double(ThreeScale::API::Client, 'remote2') }
        let(:http_client1) { instance_double(ThreeScale::API::HttpClient, 'httpclient1') }
        let(:http_client2) { instance_double(ThreeScale::API::HttpClient, 'httpclient2') }

        before :example do
          allow(remote1).to receive(:http_client).and_return(http_client1)
          allow(remote2).to receive(:http_client).and_return(http_client2)
          allow(http_client1).to receive(:endpoint).and_return(endpoint1)
          allow(http_client2).to receive(:endpoint).and_return(endpoint2)
        end

        context 'same remote, diff id' do
          let(:id1) { 1 }
          let(:id2) { 2 }
          let(:endpoint1) { 'https://w1.example.com' }
          let(:endpoint2) { 'https://w1.example.com' }

          it 'are not equal' do
            expect(svc1).not_to eq(svc2)
          end
        end

        context 'same remote, same id' do
          let(:id1) { 1 }
          let(:id2) { 1 }
          let(:endpoint1) { 'https://w1.example.com' }
          let(:endpoint2) { 'https://w1.example.com' }

          it 'are equal' do
            expect(svc1).to eq(svc2)
          end
        end

        context 'diff remote, same id' do
          let(:id1) { 1 }
          let(:id2) { 1 }
          let(:endpoint1) { 'https://w1.example.com' }
          let(:endpoint2) { 'https://w2.example.com' }

          it 'are not equal' do
            expect(svc1).not_to eq(svc2)
          end
        end

        context 'diff remote, diff id' do
          let(:id1) { 1 }
          let(:id2) { 2 }
          let(:endpoint1) { 'https://w1.example.com' }
          let(:endpoint2) { 'https://w2.example.com' }

          it 'are not equal' do
            expect(svc1).not_to eq(svc2)
          end
        end
      end
    end
  end
end
