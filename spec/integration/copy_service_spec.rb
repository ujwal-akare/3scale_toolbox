RSpec.shared_context :copy_service_stubbed_external_http_client do
  let(:external_source_service) { { 'service' => { 'id' => source_service_id } } }
  let(:external_target_service) { { 'service' => { 'id' => target_service_id } } }
  let(:external_proxy) { { 'proxy' => { 'api_backend' => 'https://example.com:443' } } }
  let(:external_methods) do
    {
      'methods' => [
        { 'method' => { 'id' => '11', 'system_name' => 'method_11', 'metric_id' => '1' } }
      ]
    }
  end
  let(:external_metrics) do
    {
      'metrics' => [
        { 'metric' => { 'id' => '1', 'system_name' => 'hits' } }
      ]
    }
  end
  let(:external_app_plan_01) do
    { 'application_plan' => { 'id' => 1, 'system_name' => 'myplan' } }
  end
  let(:external_app_plan_02) do
    { 'application_plan' => { 'id' => 2, 'system_name' => 'myotherplan' } }
  end
  let(:external_app_plans) { { 'plans' => [external_app_plan_01, external_app_plan_02] } }
  let(:external_app_limits_01) do
    {
      'limits' => [
        {
          'limit' => { 'id' => '1', 'metric_id' => '1' }
        }
      ]
    }
  end
  let(:external_app_limits_02) do
    {
      'limits' => [
        {
          'limit' => { 'id' => '2', 'metric_id' => '1' }
        }
      ]
    }
  end
  let(:external_mapping_rules) do
    {
      'mapping_rules' => [
        {
          'mapping_rule' => {
            'metric_id' => '1',
            'pattern' => '/',
            'http_method' => 'GET',
            'delta' => 1
          }
        }
      ]
    }
  end

  let(:external_proxy_policies) do
    {
      'policies_config' => [
        {
          'name' => 'apicast',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        },
        {
          'name' => 'soap',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        },
        {
          'name' => 'url_rewriting',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        },
        {
          'name' => 'ip_check',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        }
      ]
    }
  end

    let(:external_pricingrules_01) do
    {
      'pricing_rules' => [
        { 'pricing_rule' => {
          'id' => 4, 'name' => 'pr_1', 'metric_id' => '1'
        } }
      ]
    }
  end

  let(:external_pricingrules_02) do
    {
      'pricing_rules' => [
        { 'pricing_rule' => {
          'id' => 8, 'name' => 'pr_2', 'metric_id' => '1'
        } }
      ]
    }
  end

  let(:external_source_activedocs) do
    {
      'api_docs' => [
        { 'api_doc' => {
          'id' => 4, 'name' => 'ad_0', 'system_name' => 'ad_0',
          'service_id' => source_service_id.to_i
        } }
      ]
    }
  end

  let(:external_target_activedocs) do
    {
      'api_docs' => [
        { 'api_doc' => {
          'id' => 9, 'name' => 'ad_0', 'system_name' => 'ad_03333',
          'service_id' => target_service_id.to_i
        } }
      ]
    }
  end

  before :example do
    # service settings
    allow(external_source_client).to receive(:get).with('/admin/api/services/1').and_return(external_source_service)
    allow(external_target_client).to receive(:get).with('/admin/api/services/100').and_return(external_target_service)
    # proxy settings
    allow(external_source_client).to receive(:get).with('/admin/api/services/1/proxy').and_return(external_proxy)
    allow(external_target_client).to receive(:get).with('/admin/api/services/100/proxy').and_return(external_proxy)
    # methods
    allow(external_source_client).to receive(:get).with('/admin/api/services/1/metrics/1/methods').and_return(external_methods)
    allow(external_target_client).to receive(:get).with('/admin/api/services/100/metrics/1/methods').and_return(external_methods)
    # metrics
    allow(external_source_client).to receive(:get).with('/admin/api/services/1/metrics').and_return(external_metrics)
    allow(external_target_client).to receive(:get).with('/admin/api/services/100/metrics').and_return(external_metrics)
    # app plans
    allow(external_source_client).to receive(:get).with('/admin/api/services/1/application_plans').and_return(external_app_plans)
    allow(external_target_client).to receive(:get).with('/admin/api/services/100/application_plans').and_return(external_app_plans)
    # app plans limits
    allow(external_source_client).to receive(:get).with('/admin/api/application_plans/1/limits').and_return(external_app_limits_01)
    allow(external_target_client).to receive(:get).with('/admin/api/application_plans/1/limits').and_return(external_app_limits_01)
    allow(external_source_client).to receive(:get).with('/admin/api/application_plans/2/limits').and_return(external_app_limits_02)
    allow(external_target_client).to receive(:get).with('/admin/api/application_plans/2/limits').and_return(external_app_limits_02)
    # mapping rule
    allow(external_source_client).to receive(:get).with('/admin/api/services/1/proxy/mapping_rules').and_return(external_mapping_rules)
    allow(external_target_client).to receive(:get).with('/admin/api/services/100/proxy/mapping_rules').and_return(external_mapping_rules)
    # proxy policies
    allow(external_source_client).to receive(:get).with('/admin/api/services/1/proxy/policies').and_return(external_proxy_policies)
    allow(external_target_client).to receive(:get).with('/admin/api/services/100/proxy/policies').and_return(external_proxy_policies)
    # pricing rules
    allow(external_source_client).to receive(:get).with('/admin/api/application_plans/1/pricing_rules').and_return(external_pricingrules_01)
    allow(external_target_client).to receive(:get).with('/admin/api/application_plans/1/pricing_rules').and_return(external_pricingrules_01)
    allow(external_source_client).to receive(:get).with('/admin/api/application_plans/2/pricing_rules').and_return(external_pricingrules_02)
    allow(external_target_client).to receive(:get).with('/admin/api/application_plans/2/pricing_rules').and_return(external_pricingrules_02)
    ##
    # service creation calls
    expect(external_source_client).to receive(:post).with('/admin/api/services', anything).and_return(external_source_service)
    expect(external_source_client).to receive(:post).exactly(3).times.with('/admin/api/services/1/metrics/1/methods', anything).and_return('id' => 11)
    expect(external_source_client).to receive(:post).exactly(4).times.with('/admin/api/services/1/metrics', anything).and_return('id' => 1)
    expect(external_source_client).to receive(:post).exactly(2).times.with('/admin/api/services/1/application_plans', anything).and_return(external_app_plan_01)
    expect(external_source_client).to receive(:post).exactly(8).times.with('/admin/api/application_plans/1/metrics/1/limits', anything).and_return({})
    expect(external_source_client).to receive(:post).exactly(2).times.with('/admin/api/services/1/proxy/mapping_rules', anything)
    expect(external_source_client).to receive(:post).with('/admin/api/application_plans/1/metrics/1/pricing_rules', anything).exactly(2).times.and_return({})
    expect(external_source_client).to receive(:put).with('/admin/api/services/1/proxy/policies', anything).and_return({})
    # activedocs
    allow(external_source_client).to receive(:get).with('/admin/api/active_docs').and_return(external_source_activedocs)
    allow(external_target_client).to receive(:get).with('/admin/api/active_docs').and_return(external_target_activedocs)
    # crete activedocs
    expect(external_source_client).to receive(:post).with('/admin/api/active_docs', anything).and_return({})
  end
end

RSpec.shared_context :copy_service_stubbed_internal_http_client do
  let(:internal_http_client) { instance_double('ThreeScale::API::HttpClient', 'internal_http_client') }
  let(:http_client_class) { class_double('ThreeScale::API::HttpClient').as_stubbed_const }

  let(:internal_source_service) { { 'service' => { 'id' => source_service_id } } }
  let(:internal_target_service) { { 'service' => { 'id' => target_service_id } } }

  let(:internal_expected_target_service) do
    {
      body: {
        service: a_hash_including('system_name' => target_system_name)
      }
    }
  end
  let(:internal_source_proxy_service) { { 'proxy' => { 'api_backend' => 'https://example.com:443' } } }
  let(:internal_source_metrics) do
    {
      'metrics' => [
        { 'metric' => { 'id' => '1', 'system_name' => 'hits' } }
      ]
    }
  end
  let(:internal_target_metrics) do
    {
      'metrics' => [
        { 'metric' => { 'id' => '100', 'system_name' => 'hits' } }
      ]
    }
  end
  let(:internal_source_method) do
    { 'method' => { 'id' => '11', 'system_name' => 'method_11' } }
  end
  let(:internal_source_methods) do
    {
      'methods' => [internal_source_method]
    }
  end
  let(:internal_target_methods) { { 'methods' => [] } }
  let(:internal_app_plan_01) do
    { 'application_plan' => { 'id' => 1, 'system_name' => 'myplan' } }
  end
  let(:internal_app_plan_02) do
    { 'application_plan' => { 'id' => 2, 'system_name' => 'myotherplan' } }
  end
  let(:internal_source_app_plans) { { 'plans' => [internal_app_plan_01, internal_app_plan_02] } }
  let(:internal_target_app_plans) { { 'plans' => [internal_app_plan_01] } }
  let(:internal_source_mapping_rules) do
    {
      'mapping_rules' => [
        {
          'mapping_rule' => {
            'id' => '1',
            'metric_id' => '1',
            'pattern' => '/',
            'http_method' => 'GET',
            'delta' => 1
          }
        }
      ]
    }
  end
  let(:internal_target_mapping_rules) do
    {
      'mapping_rules' => [
        {
          'mapping_rule' => {
            'id' => '1',
            'metric_id' => '1',
            'pattern' => '/some',
            'http_method' => 'GET',
            'delta' => 1
          }
        }
      ]
    }
  end
  let(:internal_source_app_limits) do
    {
      'limits' => [
        {
          'limit' => { 'id' => '1', 'metric_id' => '1' }
        }
      ]
    }
  end

  let(:internal_source_pricingrules_01) do
    {
      'pricing_rules' => [
        { 'pricing_rule' => {
          'id' => 9, 'name' => 'pr_0', 'metric_id' => '1'
        } }
      ]
    }
  end

    let(:internal_proxy_policies) do
    {
      'policies_config' => [
        {
          'name' => 'apicast',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        },
        {
          'name' => 'soap',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        },
        {
          'name' => 'url_rewriting',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        },
        {
          'name' => 'ip_check',
          'version' => 'builtin',
          'configuration' => {},
          'enabled' => true
        }
      ]
    }
  end

  let(:internal_source_activedocs) do
    {
      'api_docs' => [
        { 'api_doc' => {
          'id' => 0, 'name' => 'ad_0', 'system_name' => 'ad_0',
          'service_id' => source_service_id.to_i
        } }
      ]
    }
  end

  before :example do
    # Stub http client used by command source code under test
    expect(http_client_class).to receive(:new).twice.and_return(internal_http_client)
    # create target service
    expect(internal_http_client).to receive(:post).with('/admin/api/services', internal_expected_target_service).and_return(internal_target_service)
    # get source settings
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1').and_return(internal_source_service)
    # get source proxy settings
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1/proxy').and_return(internal_source_proxy_service)
    # update target proxy settings
    expect(internal_http_client).to receive(:patch).with('/admin/api/services/100/proxy', anything).and_return(internal_source_proxy_service)
    # get source metrics
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1/metrics').at_least(:once).and_return(internal_source_metrics)
    # get target metrics
    expect(internal_http_client).to receive(:get).with('/admin/api/services/100/metrics').at_least(:once).and_return(internal_target_metrics)
    # get source methods
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1/metrics/1/methods').and_return(internal_source_methods)
    # get target methods
    expect(internal_http_client).to receive(:get).with('/admin/api/services/100/metrics/100/methods').and_return(internal_target_methods)
    # create target method
    expect(internal_http_client).to receive(:post).with('/admin/api/services/100/metrics/100/methods', anything).and_return(internal_source_method)
    # get source app plans
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1/application_plans').at_least(:once).and_return(internal_source_app_plans)
    # get target app plans
    expect(internal_http_client).to receive(:get).with('/admin/api/services/100/application_plans').at_least(:once).and_return(internal_target_app_plans)
    # create target app plan
    expect(internal_http_client).to receive(:post).with('/admin/api/services/100/application_plans', anything).and_return(internal_app_plan_01)
    # get source mapping rules
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1/proxy/mapping_rules').at_least(:once).and_return(internal_source_mapping_rules)
    # get target mapping rules
    expect(internal_http_client).to receive(:get).with('/admin/api/services/100/proxy/mapping_rules').at_least(:once).and_return(internal_target_mapping_rules)
    # create target mapping rule
    expect(internal_http_client).to receive(:post).with('/admin/api/services/100/proxy/mapping_rules', anything)
    # get source plan limits
    expect(internal_http_client).to receive(:get).with('/admin/api/application_plans/1/limits').at_least(:once).and_return(internal_source_app_limits)
    # create target plan limits
    expect(internal_http_client).to receive(:post).with('/admin/api/application_plans/1/metrics/100/limits', anything).and_return({})
    # delete target mapping rule
    expect(internal_http_client).to receive(:delete).with('/admin/api/services/100/proxy/mapping_rules/1')
    # get pricing rules
    expect(internal_http_client).to receive(:get).with('/admin/api/application_plans/1/pricing_rules').exactly(2).times.and_return(internal_source_pricingrules_01)
    # create pricing rules
    expect(internal_http_client).to receive(:post).with('/admin/api/application_plans/1/metrics/100/pricing_rules', anything)
    # get source policies
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1/proxy/policies').and_return(internal_proxy_policies)
    # put target policies
    expect(internal_http_client).to receive(:put).with('/admin/api/services/100/proxy/policies', anything)
    # get source activedocs
    expect(internal_http_client).to receive(:get).with('/admin/api/active_docs').and_return(internal_source_activedocs)
    # crete activedocs
    expect(internal_http_client).to receive(:post).with('/admin/api/active_docs', anything).and_return({})
  end
end

RSpec.shared_context :copy_service_stubbed_api3scale_clients do
  include_context :copy_service_stubbed_internal_http_client
  include_context :copy_service_stubbed_external_http_client

  let(:endpoint) { 'https://example.com' }
  let(:provider_key) { '123456789' }
  let(:verify_ssl) { true }
  let(:target_system_name) { 'stubbed_system_name' }
  let(:source_service_id) { '1' }
  let(:target_service_id) { '100' }
  let(:external_source_client) { instance_double('ThreeScale::API::HttpClient', 'external_source_client') }
  let(:external_target_client) { instance_double('ThreeScale::API::HttpClient', 'external_target_client') }
  let(:client_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end
  let(:source_client) { ThreeScale::API::Client.new(external_source_client) }
  let(:target_client) { ThreeScale::API::Client.new(external_target_client) }

  before :example do
    puts '============ RUNNING STUBBED 3SCALE API CLIENTS =========='
  end
end

RSpec.describe 'Copy Service' do
  if ENV.key?('ENDPOINT')
    include_context :real_copy_clients
    include_context :real_copy_cleanup
  else
    include_context :copy_service_stubbed_api3scale_clients
  end

  let(:source_url) { client_url }
  let(:destination_url) { client_url }
  let(:command_line_str) do
    "copy service -t #{target_system_name}" \
      " -s #{source_url} -d #{destination_url} #{source_service.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  # source service is being created for testing
  let(:source_service) { Helpers::ServiceFactory.new_service source_client }
  let(:target_service) { ThreeScaleToolbox::Entities::Service.new(id: target_service_id, remote: target_client) }

  it_behaves_like 'service copied'
end
