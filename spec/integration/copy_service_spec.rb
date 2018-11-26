require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::CopyCommand::CopyServiceSubcommand do
  include_context :api3scale_client

  # Expensive task only run once for all examples in a group
  before(:all) do
    @source_service = Helpers::ServiceFactory.new_service client
    @target_system_name = "copy_service_spec_#{Time.now.getutc.to_i}"
    source_url = client_url
    destination_url = client_url
    command_line_str = "copy service -t #{@target_system_name} " \
      " -s #{source_url} -d #{destination_url} #{@source_service.id}"
    command_line_args = command_line_str.split
    ThreeScaleToolbox::CLI.run(command_line_args)
  end

  let(:remote) { client }
  let(:target_service_id) do
    # figure out target service by system_name
    remote.list_services.find { |service| service['system_name'] == @target_system_name }['id']
  end
  # Context for shared_example
  let(:source) { @source_service }
  let(:target) { ThreeScaleToolbox::Entities::Service.new(id: target_service_id, remote: remote ) }

  it_behaves_like 'service settings copied'
  it_behaves_like 'proxy copied'
  it_behaves_like 'service methods copied'
  it_behaves_like 'service metrics copied'
  it_behaves_like 'service plans copied'
  it_behaves_like 'service plan limits copied'
  it_behaves_like 'service mapping rules copied'
end
