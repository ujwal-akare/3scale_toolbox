RSpec.describe 'Update Service' do
  include_context :real_copy_clients
  include_context :real_copy_cleanup

  let(:source_url) { client_url }
  let(:destination_url) { client_url }
  # --force
  let(:command_line_str) do
    "update service --force -t #{target_system_name}" \
      " -s #{source_url} -d #{destination_url}" \
      " #{source_service.id} #{target_service.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  # source and target services are being created for testing
  let(:source_service) { Helpers::ServiceFactory.new_service source_client }
  let(:target_service) { Helpers::ServiceFactory.new_service target_client }

  it_behaves_like 'service copied'
end
