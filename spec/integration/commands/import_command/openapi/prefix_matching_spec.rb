RSpec.describe 'OpenAPI prefix matching test' do
  include_context :oas_common_context

  let(:oas_resource_path) { File.join(resources_path, 'petstore.yaml') }
  let(:command_line_str) do
    "import openapi -t #{system_name} -d #{destination_url}" \
    " --prefix-matching" \
    " #{oas_resource_path}"
  end

  let(:mapping_rule_keys) { %w[pattern http_method delta] }

  let(:expected_mapping_rules) do
    [
      { 'pattern' => '/v2/pet', 'http_method' => 'POST', 'delta' => 1 },
      { 'pattern' => '/v2/pet', 'http_method' => 'PUT', 'delta' => 1 },
      { 'pattern' => '/v2/pet/findByStatus', 'http_method' => 'GET', 'delta' => 1 }
    ]
  end

  it 'Mapping rules patterns set with prefix matching' do
    expect(subject).to eq(0)

    # mapping rules are created
    expect(expected_mapping_rules.size).to be > 0
    # expect Set(service.mapping_rules) == Set(expected_mapping_rules)
    # with a custom identity method for mapping_rules
    expect(expected_mapping_rules).to be_subset_of(service.mapping_rules.map(&:attrs)).comparing_keys(mapping_rule_keys)
    expect(service.mapping_rules.map(&:attrs)).to be_subset_of(expected_mapping_rules).comparing_keys(mapping_rule_keys)
  end
end
