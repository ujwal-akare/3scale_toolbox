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

RSpec.shared_context :real_api3scale_clients do
  include_context :allow_net_connect
  include_context :random_name

  puts '================ RUNNING REAL 3SCALE API CLIENT ========='

  let(:endpoint) { ENV.fetch('ENDPOINT') }

  let(:provider_key) { ENV.fetch('PROVIDER_KEY') }

  let(:verify_ssl) { !(ENV.fetch('VERIFY_SSL', 'true').to_s =~ /(true|t|yes|y|1)$/i).nil? }

  let(:target_system_name) { "service_#{random_lowercase_name}_#{Time.now.getutc.to_i}" }

  let(:target_service_id) do
    # figure out target service by system_name
    target_client.list_services.find { |service| service['system_name'] == target_system_name }['id']
  end

  let(:external_client) do
    ThreeScale::API::HttpClient.new(endpoint: endpoint,
                                    provider_key: provider_key,
                                    verify_ssl: verify_ssl)
  end
  let(:source_client) { ThreeScale::API::Client.new(external_client) }
  let(:target_client) { source_client }

  let(:client_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end

  ##
  # clean up on real scenario
  after :example do
    source.delete_service
    target.delete_service
  end
end

RSpec.shared_context :toolbox_tasks_helper do
  let(:tasks_helper) do
    Class.new { include ThreeScaleToolbox::Tasks::Helper }.new
  end
end

RSpec.shared_context :copied_plans do
  # source and target has to be provided by loader context
  let(:source_plans) { source.plans }
  let(:target_plans) { target.plans }
  let(:plan_keys) { %w[name system_name custom state] }
  let(:plan_mapping_arr) { tasks_helper.application_plan_mapping(source_plans, target_plans) }
  let(:plan_mapping) { plan_mapping_arr.to_h }
end

RSpec.shared_context :copied_metrics do
  # source and target has to be provided by loader context
  let(:source_metrics) { source.metrics }
  let(:target_metrics) { target.metrics }
  let(:metric_keys) { %w[name system_name unit] }
  let(:metrics_mapping) { tasks_helper.metrics_mapping(source_metrics, target_metrics) }
end
