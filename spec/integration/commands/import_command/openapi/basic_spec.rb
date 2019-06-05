RSpec.describe 'OpenAPI import basic test' do
  include_context :oas_common_context

  let(:oas_resource_path) { File.join(resources_path, 'petstore.yaml') }
  let(:oas_resource) { YAML.safe_load(File.read(oas_resource_path)) }
  let(:command_line_str) do
    "import openapi -t #{system_name} -d #{destination_url} #{oas_resource_path}"
  end
  let(:service_active_docs) { service.activedocs }
  let(:backend_version) { '1' }
  let(:expected_methods) do
    [
      { 'friendly_name' => 'addPet', 'system_name' => 'addpet' },
      { 'friendly_name' => 'updatePet', 'system_name' => 'updatepet' },
      { 'friendly_name' => 'findPetsByStatus', 'system_name' => 'findpetsbystatus' }
    ]
  end
  let(:method_keys) { %w[friendly_name system_name] }
  let(:expected_mapping_rules) do
    [
      { 'pattern' => '/v2/pet$', 'http_method' => 'POST', 'delta' => 1 },
      { 'pattern' => '/v2/pet$', 'http_method' => 'PUT', 'delta' => 1 },
      { 'pattern' => '/v2/pet/findByStatus$', 'http_method' => 'GET', 'delta' => 1 }
    ]
  end
  let(:expected_api_backend) { 'https://echo-api.3scale.net:443' }
  let(:expected_endpoint) { URI(service_proxy.fetch('endpoint')) }
  let(:expected_activedocs_host) { "#{expected_endpoint.host}:#{expected_endpoint.port}" }
  let(:expected_public_base_scheme) { [expected_endpoint.scheme] }
  let(:expected_credentials_location) { 'query' }
  let(:expected_auth_user_key) { 'api_key' }
  let(:mapping_rule_keys) { %w[pattern http_method delta] }

  it 'expected elements are imported' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)

    # methods are created
    expect(expected_methods.size).to be > 0
    # test Set(service.methods) includes Set(expected_methods)
    # with a custom identity method for methods
    hits_id = service.hits['id']
    expect(expected_methods).to be_subset_of(service.methods(hits_id)).comparing_keys(method_keys)

    # mapping rules are created
    expect(expected_mapping_rules.size).to be > 0
    # expect Set(service.mapping_rules) == Set(expected_mapping_rules)
    # with a custom identity method for mapping_rules
    expect(expected_mapping_rules).to be_subset_of(service.mapping_rules).comparing_keys(mapping_rule_keys)
    expect(service.mapping_rules).to be_subset_of(expected_mapping_rules).comparing_keys(mapping_rule_keys)

    # service proxy is updated
    expect(service_proxy).not_to be_nil
    expect(service_proxy).to include('api_backend' => expected_api_backend,
                                     'credentials_location' => expected_credentials_location,
                                     'auth_user_key' => expected_auth_user_key)

    # activedocs are created and updated
    expect(service_active_docs.size).to eq(1)
    expect(service_active_docs[0]['name']).to eq('Swagger Petstore')
    # host updated
    expect(oas_resource['host']).not_to eq(expected_activedocs_host)
    expect(YAML.safe_load(service_active_docs[0]['body'])).to include('host' => expected_activedocs_host)
    # scheme updated
    expect(oas_resource['schemes']).not_to eq(expected_public_base_scheme)
    expect(YAML.safe_load(service_active_docs[0]['body'])).to include('schemes' => expected_public_base_scheme)
  end
end
