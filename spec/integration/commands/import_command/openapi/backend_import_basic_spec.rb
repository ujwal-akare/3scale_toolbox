RSpec.describe 'Backend import basic test' do
  include_context :resources
  include_context :random_name
  include_context :real_api3scale_client

  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:oas_resource_path) { File.join(resources_path, 'petstore.yaml') }
  let(:system_name) { "test_backend_openapi_#{random_lowercase_name}" }
  let(:command_line_str) do
    "import openapi --backend -t #{system_name} -d #{client_url} #{oas_resource_path}"
  end
  let(:backend) do
    ThreeScaleToolbox::Entities::Backend.find_by_system_name(remote: api3scale_client, system_name: system_name)
  end
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
  let(:expected_private_endpoint) { 'https://echo-api.3scale.net:443' }
  let(:mapping_rule_keys) { %w[pattern http_method delta] }

  it 'expected elements are imported' do
    expect(subject).to eq(0)

    # methods are created
    expect(expected_methods.size).to be > 0
    # test Set(backend.methods) includes Set(expected_methods)
    # with a custom identity method for methods
    expect(expected_methods).to be_subset_of(backend.methods.map(&:attrs)).comparing_keys(method_keys)

    # mapping rules are created
    expect(expected_mapping_rules.size).to be > 0
    # expect Set(backend.mapping_rules) == Set(expected_mapping_rules)
    # with a custom identity method for mapping_rules
    expect(expected_mapping_rules).to be_subset_of(backend.mapping_rules.map(&:attrs)).comparing_keys(mapping_rule_keys)
    expect(backend.mapping_rules.map(&:attrs)).to be_subset_of(expected_mapping_rules).comparing_keys(mapping_rule_keys)

    # private endpoint
    expect(backend.private_endpoint).to eq(expected_private_endpoint)
  end
end
