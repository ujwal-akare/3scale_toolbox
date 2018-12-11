require '3scale_toolbox'

RSpec.shared_context :import_oas_stubbed_api3scale_client_and_create_service do
  let(:service_id) { '100' }
  let(:service_attr) { { 'service' => { 'id' => service_id } } }

  before :example do
    ##
    # Internal http client stub
    expect(internal_http_client).to receive(:post).with('/admin/api/services', anything)
                                                  .and_return(service_attr)
  end
end

RSpec.shared_context :import_oas_real_service_id do
  let(:service_id) do
    # figure out service by system_name
    api3scale_client.list_services.find { |service| service['system_name'] == system_name }['id']
  end
end

RSpec.describe 'e2e OpenAPI import to new service' do
  if ENV.key?('ENDPOINT')
    include_context :real_api3scale_client
    include_context :import_oas_real_service_id
    include_context :import_oas_real_cleanup
  else
    include_context :import_oas_stubbed_api3scale_client
    include_context :import_oas_stubbed_api3scale_client_and_create_service
  end

  let(:destination_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end

  let(:command_line_str) { "import openapi -d #{destination_url} #{oas_resource_path}" }
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.new(id: service_id, remote: api3scale_client)
  end

  it_behaves_like 'oas imported'
end
