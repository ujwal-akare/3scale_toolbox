require '3scale_toolbox'

RSpec.shared_context :update_rules_stubbed_external_http_client do
  let(:external_source_service) { { 'service' => { 'id' => source_service_id } } }
  let(:external_target_service) { { 'service' => { 'id' => target_service_id } } }
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

  before :example do
    # metrics
    allow(external_source_client).to receive(:get).with('/admin/api/services/1/metrics').and_return(external_metrics)
    allow(external_target_client).to receive(:get).with('/admin/api/services/100/metrics').and_return(external_metrics)
    # mapping rule
    allow(external_source_client).to receive(:get).with('/admin/api/services/1/proxy/mapping_rules').and_return(external_mapping_rules)
    allow(external_target_client).to receive(:get).with('/admin/api/services/100/proxy/mapping_rules').and_return(external_mapping_rules)
    ##
    # service creation calls
    expect(external_source_client).to receive(:post).with('/admin/api/services', anything).and_return(external_source_service)
    expect(external_target_client).to receive(:post).with('/admin/api/services', anything).and_return(external_target_service)
    expect(external_source_client).to receive(:post).exactly(3).times.with('/admin/api/services/1/metrics/1/methods', anything)
    expect(external_target_client).to receive(:post).exactly(3).times.with('/admin/api/services/100/metrics/1/methods', anything)
    expect(external_source_client).to receive(:post).exactly(4).times.with('/admin/api/services/1/metrics', anything)
    expect(external_target_client).to receive(:post).exactly(4).times.with('/admin/api/services/100/metrics', anything)
    expect(external_source_client).to receive(:post).exactly(2).times.with('/admin/api/services/1/application_plans', anything).and_return(external_app_plan_01)
    expect(external_target_client).to receive(:post).exactly(2).times.with('/admin/api/services/100/application_plans', anything).and_return(external_app_plan_01)
    expect(external_source_client).to receive(:post).exactly(8).times.with('/admin/api/application_plans/1/metrics/1/limits', anything)
    expect(external_target_client).to receive(:post).exactly(8).times.with('/admin/api/application_plans/1/metrics/1/limits', anything)
    expect(external_source_client).to receive(:post).exactly(2).times.with('/admin/api/services/1/proxy/mapping_rules', anything)
    expect(external_target_client).to receive(:post).exactly(2).times.with('/admin/api/services/100/proxy/mapping_rules', anything)
  end
end

RSpec.shared_context :update_rules_stubbed_internal_http_client do
  let(:internal_http_client) { double('internal_http_client') }
  let(:http_client_class) { class_double('ThreeScale::API::HttpClient').as_stubbed_const }

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

  before :example do
    # Stub http client used by command source code under test
    expect(http_client_class).to receive(:new).twice.and_return(internal_http_client)
    # get source metrics
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1/metrics').at_least(:once).and_return(internal_source_metrics)
    # get target metrics
    expect(internal_http_client).to receive(:get).with('/admin/api/services/100/metrics').at_least(:once).and_return(internal_target_metrics)
    # get source mapping rules
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1/proxy/mapping_rules').at_least(:once).and_return(internal_source_mapping_rules)
    # get target mapping rules
    expect(internal_http_client).to receive(:get).with('/admin/api/services/100/proxy/mapping_rules').at_least(:once).and_return(internal_target_mapping_rules)
    # create target mapping rule
    expect(internal_http_client).to receive(:post).with('/admin/api/services/100/proxy/mapping_rules', anything)
    # delete target mapping rule
    expect(internal_http_client).to receive(:delete).with('/admin/api/services/100/proxy/mapping_rules/1')
  end
end

RSpec.shared_context :update_rules_stubbed_api3scale_clients do
  include_context :update_rules_stubbed_internal_http_client
  include_context :update_rules_stubbed_external_http_client

  puts '============ RUNNING STUBBED 3SCALE API CLIENTS =========='

  let(:endpoint) { 'https://example.com' }
  let(:provider_key) { '123456789' }
  let(:verify_ssl) { true }
  let(:target_system_name) { 'stubbed_system_name' }
  let(:source_service_id) { '1' }
  let(:target_service_id) { '100' }
  let(:external_source_client) { double('external_source_client') }
  let(:external_target_client) { double('external_target_client') }
  let(:client_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end
  let(:source_client) { ThreeScale::API::Client.new(external_source_client) }
  let(:target_client) { ThreeScale::API::Client.new(external_target_client) }
end

RSpec.describe 'Update Service Only Rules' do
  if ENV.key?('ENDPOINT')
    include_context :real_api3scale_clients
  else
    include_context :update_rules_stubbed_api3scale_clients
  end

  let(:source_url) { client_url }
  let(:destination_url) { client_url }
  # --force and --rules-only
  let(:command_line_str) do
    "update service --force -t #{target_system_name}" \
      " -s #{source_url} -d #{destination_url}" \
      ' --rules-only' \
      " #{source.id} #{target.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  # source and target services are being created for testing
  let(:source) { Helpers::ServiceFactory.new_service source_client }
  let(:target) { Helpers::ServiceFactory.new_service target_client }

  it_behaves_like 'service mapping rules'
end
