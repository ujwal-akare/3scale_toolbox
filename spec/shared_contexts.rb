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
  around :example do |example|
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

  let(:client_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end
end

RSpec.shared_context :real_copy_cleanup do
  after :example do
    # delete source activedocs
    source_service.activedocs.each do |activedoc|
      source_service.remote.delete_activedocs(activedoc['id'])
    end
    source_service.delete
    # delete target activedocs
    target_service.activedocs.each do |activedoc|
      target_service.remote.delete_activedocs(activedoc['id'])
    end
    target_service.delete
  end
end

RSpec.shared_context :import_oas_real_cleanup do
  after :example do
    service.activedocs.each do |activedoc|
      service.remote.delete_activedocs(activedoc['id'])
    end
    # backend cannot be deleted if used by any product
    # remove first product backend usage, and then the product itself.
    backend_usage_list = service.backend_usage_list
    backend_usage_list.each(&:delete)
    service.delete
    backend_usage_list.each do |backend_usage|
      backend = ThreeScaleToolbox::Entities::Backend.find(remote: api3scale_client, ref: backend_usage.backend_id)
      backend.delete unless backend.nil?
    end
  end
end

RSpec.shared_context :proxy_config_real_cleanup do
  after :example do
    svc = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
    unless svc.nil?
      backend_usage_list = svc.backend_usage_list
      backend_usage_list.each(&:delete)
      svc.delete
      backend_usage_list.each do |backend_usage|
        backend = ThreeScaleToolbox::Entities::Backend.find(remote: api3scale_client, ref: backend_usage.backend_id)
        backend.delete unless backend.nil?
      end
    end
  end
end

RSpec.shared_context :copied_plans do
  # source and target has to be provided by loader context
  let(:source_plans) { source_service.plans }
  let(:target_plans) { target_service.plans }
  let(:plan_keys) { %w[name system_name custom state] }
  let(:plan_mapping_arr) do
    ThreeScaleToolbox::Helper.application_plan_mapping(source_plans, target_plans)
  end
  let(:plan_mapping) do
    plan_mapping_arr.each_with_object({}) do |(a, b), hash|
      hash[a.id] = b
    end
  end
end

RSpec.shared_context :copied_metrics do
  # source and target has to be provided by loader context
  let(:source_metrics) { source_service.metrics }
  let(:target_metrics) { target_service.metrics }
  let(:metric_keys) { %w[name system_name unit] }
  let(:metrics_mapping) do
    ThreeScaleToolbox::Helper.metrics_mapping(source_metrics, target_metrics)
  end
end

RSpec.shared_context :oas_common_context do
  include_context :resources
  include_context :random_name
  include_context :real_api3scale_client
  include_context :import_oas_real_cleanup

  let(:system_name) { "test_openapi_#{random_lowercase_name}" }
  let(:destination_url) { client_url }
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.find_by_system_name(remote: api3scale_client, system_name: system_name)
  end
  let(:service_proxy) { service.proxy }
  let(:service_settings) { service.attrs }
end
