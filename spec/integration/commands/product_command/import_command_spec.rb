RSpec.describe 'Product import from YAML' do
  include_context :real_api3scale_client
  include_context :resources
  include_context :random_name
  include_context :real_copy_cleanup
  include_context :temp_dir

  let(:remote) { client_url }
  let(:product_system_name) { "product_#{random_lowercase_name}_#{Time.now.getutc.to_i}" }
  let(:backend_01_system_name) { "backend01_#{random_lowercase_name}_#{Time.now.getutc.to_i}" }
  let(:backend_02_system_name) { "backend02_#{random_lowercase_name}_#{Time.now.getutc.to_i}" }
  let(:source_file) { File.join(resources_path, 'product_cr.yaml') }
  let(:source_content) { YAML.load(File.read(source_file)) }
  let(:updated_content) do
    # Update product system_name
    # Update backend's system_name
    # Update limit and pricing rule references
    source_content.clone.tap do |new_content|
      product = new_content.fetch('items').select { |item| item['kind'] == 'Product' }[0]
      product['spec']['systemName'] = product_system_name
      backend_usages = product['spec']['backendUsages']
      backend_usages[backend_01_system_name] = backend_usages.delete 'backend_01'
      backend_usages[backend_02_system_name] = backend_usages.delete 'backend_02'
      backend_01 = new_content.fetch('items').select { |item| item['kind'] == 'Backend' && item.dig('spec', 'systemName') == 'backend_01' }[0]
      backend_01['spec']['systemName'] = backend_01_system_name
      backend_02 = new_content.fetch('items').select { |item| item['kind'] == 'Backend' && item.dig('spec', 'systemName') == 'backend_02' }[0]
      backend_02['spec']['systemName'] = backend_02_system_name
      backend_01_limits = product.dig('spec', 'applicationPlans').values.flat_map do |plan|
        plan.fetch('limits').select { |limit| limit.dig('metricMethodRef', 'backend') == 'backend_01' }
      end
      backend_01_limits.each { |limit| limit['metricMethodRef']['backend'] = backend_01_system_name }
      backend_02_limits = product.dig('spec', 'applicationPlans').values.flat_map do |plan|
        plan.fetch('limits').select { |limit| limit.dig('metricMethodRef', 'backend') == 'backend_02' }
      end
      backend_02_limits.each { |limit| limit['metricMethodRef']['backend'] = backend_02_system_name }
      backend_01_pricing_rules = product.dig('spec', 'applicationPlans').values.flat_map do |plan|
        plan.fetch('pricingRules').select { |pr| pr.dig('metricMethodRef', 'backend') == 'backend_01' }
      end
      backend_01_pricing_rules.each { |pr| pr['metricMethodRef']['backend'] = backend_01_system_name }
      backend_02_pricing_rules = product.dig('spec', 'applicationPlans').values.flat_map do |plan|
        plan.fetch('pricingRules').select { |pr| pr.dig('metricMethodRef', 'backend') == 'backend_02' }
      end
      backend_02_pricing_rules.each { |pr| pr['metricMethodRef']['backend'] = backend_02_system_name }
    end
  end
  let(:updated_resource) { tmp_dir.join('product.yaml').tap { |conf| conf.write(updated_content.to_yaml) } }
  let(:product_source_list) do
    updated_content.fetch('items').select { |item| item['kind'] == 'Product' }.map(&ThreeScaleToolbox::CRD::ProductParser.method(:new))
  end
  let(:backend_source_list) do
    updated_content.fetch('items').select { |item| item['kind'] == 'Backend' }.map(&ThreeScaleToolbox::CRD::BackendParser.method(:new))
  end
  let(:crd_remote) { ThreeScaleToolbox::CRD::Remote.new(product_source_list, backend_source_list) }
  let(:source_service) do
    ThreeScaleToolbox::Entities::Service.find(ref: product_system_name, remote: crd_remote)
  end
  let(:target_service) do
    ThreeScaleToolbox::Entities::Service.find(ref: product_system_name, remote: api3scale_client)
  end
  let(:command_line_str) { "product import #{remote} -f #{updated_resource}" }
  let(:command_line_args) { command_line_str.split }

  subject { ThreeScaleToolbox::CLI.run(command_line_args) }

  it_behaves_like 'service copied'
end
