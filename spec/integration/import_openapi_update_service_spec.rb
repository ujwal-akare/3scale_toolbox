require '3scale_toolbox'

RSpec.shared_context :import_oas_stubbed_api3scale_client_for_existing_service do
  let(:service_attr) { { 'service' => { 'id' => '100' } } }

  before :example do
    ##
    # External http client stub
    expect(external_http_client).to receive(:post).with('/admin/api/services', anything)
                                                  .and_return(service_attr)
  end
end

RSpec.describe 'e2e OpenAPI import to existing service' do
  if ENV.key?('ENDPOINT')
    include_context :real_api3scale_client
    include_context :import_oas_real_cleanup
  else
    include_context :import_oas_stubbed_api3scale_client
    include_context :import_oas_stubbed_api3scale_client_for_existing_service
  end

  let(:destination_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end

  let(:service) do
    service_name = system_name
    service_obj = { 'name' => service_name }
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service: service_obj, system_name: system_name
    )
  end
  let(:service_id) { service.id }
  let(:command_line_str) do
    "import openapi -d #{destination_url} --service #{service_id} #{oas_resource_path}"
  end
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }

  it_behaves_like 'oas imported'
end
