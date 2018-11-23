require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::CopyCommand::CopyServiceSubcommand do
  include_context :source_service

  let(:service_id) { source_service.id }
  let(:source_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end
  let(:destination_url) { source_url }
  let(:system_name) { "copy_service_spec_#{Time.now.getutc.to_i}" }
  let(:command_line_str) { "copy service -t #{system_name} -s #{source_url} -d #{destination_url} #{service_id}" }
  let(:command_line_args) { command_line_str.split }
  let(:run_test) { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:target_service_id) do
    # create target by invoking command under test
    # figure out target service by system_name
    run_test
    client.list_services.find { |service| service['system_name'] == system_name }['id']
  end
  let(:source) { source_service }
  let(:target) { ThreeScaleToolbox::Entities::Service.new(id: target_service_id, remote: client) }

  it_behaves_like 'a copied service'
end
