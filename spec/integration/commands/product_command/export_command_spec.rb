RSpec.describe 'Product export to YAML' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :temp_dir

  let(:file) { tmp_dir.join('product.yaml') }
  let(:remote) { client_url }
  let(:product) { Helpers::ServiceFactory.new_service api3scale_client }

  let(:command_line_str) { "product export #{remote} #{product.id} -f #{file}" }
  let(:command_line_args) { command_line_str.split }
  let(:backend_01) { Helpers::BackendFactory.new_backend api3scale_client }
  let(:backend_02) { Helpers::BackendFactory.new_backend api3scale_client }

  subject { ThreeScaleToolbox::CLI.run(command_line_args) }

  before :example do
      # backend_usage_01
      attrs = { 'backend_api_id' => backend_01.id, 'service_id' => product.id, 'path' => '/v1' }
      ThreeScaleToolbox::Entities::BackendUsage.create(product: product, attrs: attrs)
      # backend_usage_02
      attrs = { 'backend_api_id' => backend_02.id, 'service_id' => product.id, 'path' => '/v2' }
      ThreeScaleToolbox::Entities::BackendUsage.create(product: product, attrs: attrs)

      # Apicast Self Managed deployment option
      # UserKey Auth mode
      product.update('deployment_option' => 'self_managed', 'backend_version' => '1')
  end

  after :example do
    product.backend_usage_list.each(&:delete)
    backend_01.delete
    backend_02.delete
    product.delete
  end

  it 'serialized content is correct' do
    expect(subject).to eq(0)
    deserialized_content = YAML.safe_load(file.read)
    product_cr_raw = deserialized_content.fetch('items').select { |item| item['kind'] == 'Product' }[0]
    expect(product_cr_raw).not_to be_nil
    product_cr = ThreeScaleToolbox::CRD::ProductParser.new(product_cr_raw)
    backend_cr_raw_list = deserialized_content.fetch('items').select { |item| item['kind'] == 'Backend' }
    expect(backend_cr_raw_list.length).to eq 2
    backend_cr_list = backend_cr_raw_list.map(&ThreeScaleToolbox::CRD::BackendParser.method(:new))

    # CRD Remote runs validations on initialization
    ThreeScaleToolbox::CRD::Remote.new([product_cr], backend_cr_list)

    # Check exported product attrs
    expect(product_cr.name).to eq product.name
    expect(product_cr.system_name).to eq product.system_name

    # Check exported product metrics
    expect(product_cr.metrics.length).to eq(product.metrics.length)
    expect(product_cr.metrics.map(&:system_name)).to match_array(product.metrics.map(&:system_name))
    expect(product_cr.metrics.map(&:friendly_name)).to match_array(product.metrics.map(&:friendly_name))
    expect(product_cr.metrics.map(&:description)).to match_array(product.metrics.map(&:description))
    expect(product_cr.metrics.map(&:unit)).to match_array(product.metrics.map(&:unit))

    # Check exported product metrics
    expect(product_cr.methods.length).to eq(product.methods.length)
    expect(product_cr.methods.map(&:system_name)).to match_array(product.methods.map(&:system_name))
    expect(product_cr.methods.map(&:friendly_name)).to match_array(product.methods.map(&:friendly_name))
    expect(product_cr.methods.map(&:description)).to match_array(product.methods.map(&:description))

    # Index metric_id -> metric_system_name
    metric_index = (product.methods + product.metrics).each_with_object({}) { |metric, h| h[metric.id] = metric.system_name }

    # Check exported mapping rules
    product_mapping_rules = product.mapping_rules
    expect(product_cr.mapping_rules.length).to eq(product_mapping_rules.length)
    expect(product_cr.mapping_rules.map(&:http_method)).to match_array(product_mapping_rules.map(&:http_method))
    expect(product_cr.mapping_rules.map(&:pattern)).to match_array(product_mapping_rules.map(&:pattern))
    expect(product_cr.mapping_rules.map(&:delta)).to match_array(product_mapping_rules.map(&:delta))
    expect(product_cr.mapping_rules.map(&:last)).to match_array(product_mapping_rules.map(&:last))
    expect(product_cr.mapping_rules.map(&:metric_ref)).to match_array(product_mapping_rules.map { |mr| metric_index.fetch(mr.metric_id)})

    # Check exported policy chain
    product_policies = product.policies
    expect(product_cr.policy_chain.length).to eq(product_policies.length)
    expect(product_cr.policy_chain.map(&:name)).to match_array(product_policies.map { |p| p.fetch('name') })
    expect(product_cr.policy_chain.map(&:version)).to match_array(product_policies.map { |p| p.fetch('version') })
    expect(product_cr.policy_chain.map(&:configuration)).to match_array(product_policies.map { |p| p.fetch('configuration') })
    expect(product_cr.policy_chain.map(&:enabled)).to match_array(product_policies.map { |p| p.fetch('enabled') })

    # Check exported backend usages
    expect(product_cr.backend_usages.length).to eq 2 # backend_01 and backend_02
    product_backend_usages = product.backend_usage_list
    expect(product_cr.backend_usages.length).to eq(product_backend_usages.length)
    expect(product_cr.backend_usages.map(&:backend_system_name)).to match_array(product_backend_usages.map(&:backend).map(&:system_name))
    expect(product_cr.backend_usages.map(&:path)).to match_array(product_backend_usages.map(&:path))

    # Check exported deployment
    expect(product_cr.deployment_option).to eq 'self_managed'
    expect(product_cr.backend_version).to eq '1'

    # Check exported application plans
    product_plans = product.plans
    expect(product_cr.application_plans.length).to eq(product_plans.length)
    expect(product_cr.application_plans.map(&:system_name)).to match_array(product_plans.map(&:system_name))
    expect(product_cr.application_plans.map(&:name)).to match_array(product_plans.map(&:name))
    # Check exported plan limits
    expect(product_cr.application_plans.map(&:limits).map(&:length).reduce(:+)).to eq(product_plans.map(&:limits).map(&:length).reduce(:+))
    # Check exported plan pricing rules
    expect(product_cr.application_plans.map(&:pricing_rules).map(&:length).reduce(:+)).to eq(product_plans.map(&:pricing_rules).map(&:length).reduce(:+))

    # Check exported backends
    backend_cr_list.each do |backend_cr|
      backend = ThreeScaleToolbox::Entities::Backend.find_by_system_name(remote: api3scale_client, system_name: backend_cr.system_name)
      expect(backend).not_to be_nil

      # Check exported backend attrs
      expect(backend_cr.name).to eq backend.name
      expect(backend_cr.private_endpoint).to eq backend.private_endpoint

      # Check exported backend metrics
      expect(backend_cr.metrics.length).to eq(backend.metrics.length)
      expect(backend_cr.metrics.map(&:system_name)).to match_array(backend.metrics.map(&:system_name))
      expect(backend_cr.metrics.map(&:friendly_name)).to match_array(backend.metrics.map(&:friendly_name))
      expect(backend_cr.metrics.map(&:description)).to match_array(backend.metrics.map(&:description))
      expect(backend_cr.metrics.map(&:unit)).to match_array(backend.metrics.map(&:unit))

      # Check exported backend metrics
      expect(backend_cr.methods.length).to eq(backend.methods.length)
      expect(backend_cr.methods.map(&:system_name)).to match_array(backend.methods.map(&:system_name))
      expect(backend_cr.methods.map(&:friendly_name)).to match_array(backend.methods.map(&:friendly_name))
      expect(backend_cr.methods.map(&:description)).to match_array(backend.methods.map(&:description))

      # Index metric_id -> metric_system_name
      metric_index = (backend.methods + backend.metrics).each_with_object({}) { |metric, h| h[metric.id] = metric.system_name }

      # Check exported mapping rules
      backend_mapping_rules = backend.mapping_rules
      expect(backend_cr.mapping_rules.length).to eq(backend_mapping_rules.length)
      expect(backend_cr.mapping_rules.map(&:http_method)).to match_array(backend_mapping_rules.map(&:http_method))
      expect(backend_cr.mapping_rules.map(&:pattern)).to match_array(backend_mapping_rules.map(&:pattern))
      expect(backend_cr.mapping_rules.map(&:delta)).to match_array(backend_mapping_rules.map(&:delta))
      expect(backend_cr.mapping_rules.map(&:last)).to match_array(backend_mapping_rules.map(&:last))
      expect(backend_cr.mapping_rules.map(&:metric_ref)).to match_array(backend_mapping_rules.map { |mr| metric_index.fetch(mr.metric_id)})
    end
  end
end
