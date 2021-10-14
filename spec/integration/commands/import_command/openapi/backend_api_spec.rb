RSpec.describe 'OpenAPI import backend api related parameters test' do
  include_context :oas_common_context

  let(:expected_backend_api_secret_token) { "secret_token" }
  let(:expected_backend_api_hostname_rewrite) { "backendapihost.com" }
  let(:oas_resource_path) { File.join(resources_path, 'petstore.yaml') }
  let(:command_line_str) do
    "import openapi -t #{system_name} -d #{destination_url}" \
    " --backend-api-secret-token=#{expected_backend_api_secret_token}" \
    " --backend-api-host-header=#{expected_backend_api_hostname_rewrite}" \
    " #{oas_resource_path}"
  end

  it 'expected backend api configuration options are set' do
    expect(subject).to eq(0)

    expect(service_proxy).to include(
      'secret_token' => expected_backend_api_secret_token,
      'hostname_rewrite' => expected_backend_api_hostname_rewrite,
    )
  end
end
