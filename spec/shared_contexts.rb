require 'erb'
require 'tmpdir'
require 'pathname'

RSpec.shared_context :random_name do
  def random_lowercase_name
    [*('a'..'z')].sample(8).join
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

RSpec.shared_context :api3scale_client do
  let(:endpoint) { ENV.fetch('ENDPOINT') }
  let(:provider_key) { ENV.fetch('PROVIDER_KEY') }
  let(:verify_ssl) { !(ENV.fetch('VERIFY_SSL', 'true').to_s =~ /(true|t|yes|y|1)$/i).nil? }
  subject(:client) do
    ThreeScale::API.new(endpoint: endpoint, provider_key: provider_key, verify_ssl: verify_ssl)
  end
end

RSpec.shared_context :source_service do
  include_context :api3scale_client
  include_context :random_name

  let(:source_service_name) { "API_TEST_#{Time.now.getutc.to_i}" }
  let(:source_system_name) { source_service_name.delete("\s").downcase }
  let(:source_service_obj) { { 'name' => source_service_name } }
  subject(:source_service) do
    service = ThreeScaleToolbox::Entities::Service.create(
      remote: client, service: source_service_obj, system_name: source_system_name
    )
    # methods
    hits_id = service.hits['id']
    3.times.each do
      method = { 'system_name' => random_lowercase_name, 'friendly_name' => random_lowercase_name }
      service.create_method(hits_id, method)
    end

    # metrics
    4.times.each do
      name = random_lowercase_name
      metric = { 'name' => name, 'system_name' => name, 'unit' => '1' }
      service.create_metric(metric)
    end

    # application plans
    2.times.each do
      name = random_lowercase_name
      application_plan = {
        'name' => name, 'state' => 'published', 'default' => false,
        'custom' => false, 'system_name' => name
      }
      plan = service.create_application_plan(application_plan)

      # limits (only limits for hits metric)
      %w[day week month year].each do |period|
        limit = { 'period' => period, 'value' => 10_000 }
        service.create_application_plan_limit(plan.fetch('id'), hits_id, limit)
      end
    end

    # mapping rules (only mapping rules for hits metric)
    2.times.each do |idx|
      mapping_rule = {
        'metric_id' => hits_id, 'pattern' => "/rule#{idx}",
        'http_method' => 'GET',
        'delta' => 1
      }

      service.create_mapping_rule(mapping_rule)
    end

    service
  end
end
