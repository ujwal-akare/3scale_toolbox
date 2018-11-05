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

RSpec.shared_context :source_service_data do
  include_context :random_name

  let(:source_service_params) do
    %w[
      name backend_version deployment_option description
      system_name end_user_registration_required
      support_email tech_support_email admin_support_email
    ]
  end

  let(:source_service_obj) do
    source_service_params.each_with_object({}) do |key, target|
      target[key] = random_lowercase_name
    end
  end
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
