RSpec.describe 'Copy Service' do
  include_context :real_copy_clients
  include_context :real_copy_cleanup

  let(:source_url) { client_url }
  let(:destination_url) { client_url }
  let(:command_line_str) do
    "copy service -t #{target_system_name}" \
      " -s #{source_url} -d #{destination_url} #{source_service.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  # source service is being created for testing
  let(:source_service) { Helpers::ServiceFactory.new_service source_client }
  let(:target_service) { ThreeScaleToolbox::Entities::Service.new(id: target_service_id, remote: target_client) }

  it_behaves_like 'service copied'
end
