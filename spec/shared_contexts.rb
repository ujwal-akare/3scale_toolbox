require 'erb'
require 'tmpdir'
require 'pathname'

RSpec.shared_context :random_name do
  def random_lowercase_name
    Helpers.random_lowercase_name
  end
end

RSpec.shared_context :resources do
  let(:resources_path) { File.join(File.dirname(__FILE__), 'resources') }
end

RSpec.shared_context :temp_dir do
  around(:each) do |example|
    Dir.mktmpdir('3scale_toolbox_rspec-') do |dir|
      @tmp_dir = Pathname.new(dir)
      example.run
    end
  end

  let(:tmp_dir) { @tmp_dir }
end

class PluginRenderer
  attr_accessor :command_class_name, :command_name

  def initialize(template)
    @renderer = ERB.new(template)
  end

  def render
    @renderer.result(binding)
  end
end

RSpec.shared_context :plugin do
  include_context :resources

  def get_plugin_content(command_class_name, command_name)
    plugin_template = File.read(
      File.join(resources_path, '3scale_toolbox_plugin_template.erb')
    )
    plugin_renderer = PluginRenderer.new(plugin_template)
    plugin_renderer.command_class_name = command_class_name
    plugin_renderer.command_name = command_name
    plugin_renderer.render
  end
end

RSpec.shared_context :allow_net_connect do
  around :context do |example|
    WebMock.allow_net_connect!
    example.run
    WebMock.disable_net_connect!
  end
end

RSpec.shared_context :real_api3scale_client do
  include_context :allow_net_connect

  let(:endpoint) { ENV.fetch('ENDPOINT') }

  let(:provider_key) { ENV.fetch('PROVIDER_KEY') }

  let(:verify_ssl) { !(ENV.fetch('VERIFY_SSL', 'true').to_s =~ /(true|t|yes|y|1)$/i).nil? }

  let(:http_client) do
    ThreeScale::API::HttpClient.new(endpoint: endpoint,
                                    provider_key: provider_key,
                                    verify_ssl: verify_ssl)
  end
  let(:api3scale_client) { ThreeScale::API::Client.new(http_client) }

  before :example do
    puts '================ RUNNING REAL 3SCALE API CLIENT ========='
  end
end

RSpec.shared_context :real_copy_clients do
  include_context :real_api3scale_client
  include_context :random_name

  let(:target_system_name) { "service_#{random_lowercase_name}_#{Time.now.getutc.to_i}" }
  let(:target_service_id) do
    # figure out target service by system_name
    target_client.list_services.find { |service| service['system_name'] == target_system_name }['id']
  end
  let(:client_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end
  let(:source_client) { ThreeScale::API::Client.new(http_client) }
  let(:target_client) { ThreeScale::API::Client.new(http_client) }
end

RSpec.shared_context :real_copy_cleanup do
  after :example do
    # delete source activedocs
    source_service.list_activedocs.each do |activedoc|
      source_service.remote.delete_activedocs(activedoc['id'])
    end
    source_service.delete_service
    # delete target activedocs
    target_service.list_activedocs.each do |activedoc|
      target_service.remote.delete_activedocs(activedoc['id'])
    end
    target_service.delete_service
  end
end

RSpec.shared_context :import_oas_real_cleanup do
  after :example do
    service.list_activedocs.each do |activedoc|
      service.remote.delete_activedocs(activedoc['id'])
    end
    service.delete_service
  end
end

RSpec.shared_context :toolbox_tasks_helper do
  let(:tasks_helper) do
    Class.new { include ThreeScaleToolbox::Tasks::Helper }.new
  end
end

RSpec.shared_context :copied_plans do
  # source and target has to be provided by loader context
  let(:source_plans) { source_service.plans }
  let(:target_plans) { target_service.plans }
  let(:plan_keys) { %w[name system_name custom state] }
  let(:plan_mapping_arr) { tasks_helper.application_plan_mapping(source_plans, target_plans) }
  let(:plan_mapping) { plan_mapping_arr.to_h }
end

RSpec.shared_context :copied_metrics do
  # source and target has to be provided by loader context
  let(:source_metrics) { source_service.metrics }
  let(:target_metrics) { target_service.metrics }
  let(:metric_keys) { %w[name system_name unit] }
  let(:metrics_mapping) { tasks_helper.metrics_mapping(source_metrics, target_metrics) }
end

RSpec.shared_context :oas_common_context do
  include_context :resources
  include_context :random_name
  if ENV.key?('ENDPOINT')
    include_context :real_api3scale_client
    include_context :import_oas_real_cleanup
  end
  let(:system_name) { "test_openapi_#{random_lowercase_name}" }
  let(:destination_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:service_id) do
    # figure out service by system_name
    api3scale_client.list_services.find { |service| service['system_name'] == system_name }['id']
  end
  let(:service) do
    ThreeScaleToolbox::Entities::Service.new(id: service_id, remote: api3scale_client)
  end
  let(:service_proxy) { service.show_proxy }
  let(:service_settings) { service.show_service }
end

RSpec.shared_context :oas_common_mocked_context do
  let(:internal_http_client) { double('internal_http_client') }
  let(:http_client_class) { class_double('ThreeScale::API::HttpClient').as_stubbed_const }

  let(:endpoint) { 'https://example.com' }
  let(:provider_key) { '123456789' }
  let(:verify_ssl) { true }
  let(:external_http_client) { double('external_http_client') }
  let(:api3scale_client) { ThreeScale::API::Client.new(external_http_client) }
  let(:fake_service_id) { 100 }

  let(:service_attr) do
    { 'service' => { 'id' => fake_service_id,
                     'system_name' => system_name,
                     'backend_version' => backend_version } }
  end
  let(:metrics) do
    {
      'metrics' => [
        { 'metric' => { 'id' => '1', 'system_name' => 'hits' } }
      ]
    }
  end

  let(:service_policies) do
    {
      'policies_config' => [
        { 'name' => 'apicast', 'version' => 'builtin', 'configuration' => {}, 'enabled' => true }
      ]
    }
  end

  let(:existing_mapping_rules) do
    {
      'mapping_rules' => [
        { 'mapping_rule' => { 'id' => '1', 'delta' => 1, 'http_method' => 'GET', 'pattern' => '/' } }
      ]
    }
  end

  let(:existing_services) do
    {
      'services' => [
        { 'service' => { 'id' => fake_service_id, 'system_name' => system_name } }
      ]
    }
  end

  before :example do
    puts '============ RUNNING STUBBED 3SCALE API CLIENT =========='
    ##
    # Internal http client stub
    allow(internal_http_client).to receive(:post).with('/admin/api/services', anything)
                                                 .and_return(service_attr)
    allow(http_client_class).to receive(:new).and_return(internal_http_client)
    allow(internal_http_client).to receive(:get).with('/admin/api/services/100/metrics')
                                                .and_return(metrics)
    allow(internal_http_client).to receive(:post).with('/admin/api/services/100/metrics/1/methods',
                                                       anything).at_least(:once)
                                                 .and_return('id' => '1')
    allow(internal_http_client).to receive(:get).with('/admin/api/services/100/proxy/mapping_rules').and_return(existing_mapping_rules)
    allow(internal_http_client).to receive(:delete).with('/admin/api/services/100/proxy/mapping_rules/1')
    allow(internal_http_client).to receive(:post).with('/admin/api/services/100/proxy/mapping_rules', anything)
                                                 .at_least(:once)
    allow(internal_http_client).to receive(:post).with('/admin/api/active_docs', anything)
                                                 .and_return({})
    allow(internal_http_client).to receive(:get).with('/admin/api/services/100')
                                                .and_return(service_attr)
    allow(internal_http_client).to receive(:patch).with('/admin/api/services/100/proxy', anything)
                                                  .and_return({})
    allow(internal_http_client).to receive(:get).with('/admin/api/services/100/proxy/policies')
                                                .and_return(service_policies)
    allow(internal_http_client).to receive(:patch).with('/admin/api/services/100/proxy/oidc_configuration', anything).and_return({})
    allow(internal_http_client).to receive(:put).with('/admin/api/services/100/proxy/policies',
                                                      anything).and_return({})
    ##
    # External http client stub
    allow(external_http_client).to receive(:post).with('/admin/api/services', anything)
                                                 .and_return(service_attr)
    allow(external_http_client).to receive(:get).with('/admin/api/services')
                                                .and_return(existing_services)
    allow(external_http_client).to receive(:get).with('/admin/api/services/100/metrics')
                                                .and_return(metrics)
    allow(external_http_client).to receive(:get).with('/admin/api/services/100/proxy')
                                                .and_return(external_proxy)
    allow(external_http_client).to receive(:get).with('/admin/api/services/100')
                                                .and_return(service_attr)
  end
end
