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

RSpec.shared_context :api3scale_client do
  def endpoint
    ENV.fetch('ENDPOINT')
  end

  def provider_key
    ENV.fetch('PROVIDER_KEY')
  end

  def verify_ssl
    !(ENV.fetch('VERIFY_SSL', 'true').to_s =~ /(true|t|yes|y|1)$/i).nil?
  end

  def client_url
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end

  def client
    ThreeScale::API.new(endpoint: endpoint,
                        provider_key: provider_key,
                        verify_ssl: verify_ssl)
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

RSpec.shared_context :allow_net_connect do
  # cannot use around hook to enable net connect
  # around hook is per example and context level before hook needs net connect
  # cannot use configuration level (in spec_helper.rb ) before hook with conditions, like
  # configure.before type: :net {}
  # because they are executed after the before hook for context level.
  before :context do
    WebMock.allow_net_connect!
  end

  after :context do
    WebMock.disable_net_connect!
  end
end
