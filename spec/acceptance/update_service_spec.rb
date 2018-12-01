require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::UpdateCommand::UpdateServiceSubcommand do
  include_context :allow_net_connect
  include_context :random_name
  include_context :api3scale_client

  context 'update all' do
    # Expensive task only run once for all examples in a group
    before :context do
      @source_service = Helpers::ServiceFactory.new_service client
      @target_service = Helpers::ServiceFactory.new_service client
      @target_system_name = "update_#{random_lowercase_name}_#{Time.now.getutc.to_i}"
      source_url = client_url
      destination_url = client_url
      # --force
      command_line_str = "update service --force -t #{@target_system_name}" \
        " -s #{source_url} -d #{destination_url}" \
        " #{@source_service.id} #{@target_service.id}"
      command_line_args = command_line_str.split
      ThreeScaleToolbox::CLI.run(command_line_args)
    end

    let(:remote) { client }
    # Context for shared_example
    let(:source) { @source_service }
    let(:target) { @target_service }

    it_behaves_like 'service settings copied'
    it_behaves_like 'proxy copied'
    it_behaves_like 'service methods copied'
    it_behaves_like 'service metrics copied'
    it_behaves_like 'service plans copied'
    it_behaves_like 'service plan limits copied'
    it_behaves_like 'service mapping rules copied'
  end

  context 'rules only' do
    # Expensive task only run once for all examples in a group
    before(:all) do
      @source_service = Helpers::ServiceFactory.new_service client
      @target_service = Helpers::ServiceFactory.new_service client
      @target_system_name = "copy_service_spec_#{Time.now.getutc.to_i}"
      source_url = client_url
      destination_url = client_url
      # --force
      command_line_str = "update service --force -t #{@target_system_name}" \
        " -s #{source_url} -d #{destination_url}" \
        ' --rules-only' \
        " #{@source_service.id} #{@target_service.id}"
      command_line_args = command_line_str.split
      ThreeScaleToolbox::CLI.run(command_line_args)
    end

    let(:remote) { client }
    # Context for shared_example
    let(:source) { @source_service }
    let(:target) { @target_service }

    it_behaves_like 'service mapping rules copied'
  end
end
