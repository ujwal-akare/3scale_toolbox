RSpec.describe 'Copy Service' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :real_copy_cleanup

  let(:source_url) { client_url }
  let(:destination_url) { client_url }
  let(:target_system_name) { "service_#{random_lowercase_name}_#{Time.now.getutc.to_i}" }
  let(:command_line_str) do
    "copy service -t #{target_system_name}" \
      " -s #{source_url} -d #{destination_url} #{source_service.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  # source service is being created for testing
  let(:source_service) { Helpers::ServiceFactory.new_service api3scale_client }
  let(:target_service) do
    ThreeScaleToolbox::Entities::Service.find(ref: target_system_name, remote: api3scale_client)
  end

  it_behaves_like 'service copied'
end
