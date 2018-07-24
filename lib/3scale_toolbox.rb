require '3scale_toolbox/configuration'

module ThreeScaleToolbox
  @config_file = nil
  @configuration = nil

  def self.load_plugins
    plugin_paths.each { |plugin_path| require plugin_path }
  end

  def self.plugin_paths
    Gem.find_files('3scale_toolbox_plugin')
  end

  def self.config_file
    # 3SCALERC env var has priority over $HOME/.3scalerc.yaml file
    @config_file ||= ENV['THREESCALERC']
    @config_file ||= File.join Gem.user_home, '.3scalerc.yaml'
  end

  def self.config_file=(config_file)
    @config_file = config_file
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end
end
