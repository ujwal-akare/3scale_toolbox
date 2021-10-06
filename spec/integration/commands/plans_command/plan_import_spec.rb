RSpec.describe 'Application Plan Import' do
  include_context :real_api3scale_client
  include_context :resources
  include_context :temp_dir
  include_context :random_name

  let(:file_template) { File.join(resources_path, 'plan.yaml') }
  let(:file) { tmp_dir.join('plan.yaml') }
  let(:remote) { client_url }

  let(:backend) do
    attrs = {
      'name' => "API_TEST_#{Helpers.random_lowercase_name}_#{Time.now.getutc.to_i}",
      'private_endpoint' => "https://#{Helpers.random_lowercase_name}.example.com"
    }

    ThreeScaleToolbox::Entities::Backend.create(remote: api3scale_client, attrs: attrs)
  end

  let(:service_system_name) { "service_#{random_lowercase_name}" }
  let(:service_obj) { { 'name' => service_system_name, 'system_name' => service_system_name } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_obj
    )
  end

  # plan system name does not conflict with app plans belonging to other services
  let(:command_line_str) do
    "application-plan import -f #{file} #{remote} #{service.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }

  before :example do
    # replace backend system name in plan.yaml as it is unique per test
    file.write(File.read(file_template).gsub('__BACKEND_SYSTEM_NAME__', backend.system_name))

    # backend_usage_01
    attrs = { 'backend_api_id' => backend.id, 'service_id' => service.id, 'path' => '/v1' }
    ThreeScaleToolbox::Entities::BackendUsage.create(product: service, attrs: attrs)
  end

  after :example do
    service.backend_usage_list.each(&:delete)
    backend.delete
    service.delete
  end

  it do
    expect(subject).to eq(0)
    file_plan_obj = YAML.safe_load(File.read(file))
    file_plan = file_plan_obj['plan']
    file_limits = file_plan_obj['limits']
    file_pricingrules = file_plan_obj['pricingrules']
    file_features = file_plan_obj['plan_features']
    file_feature = file_features[0]
    file_product_metrics = file_plan_obj['metrics'].reject { |m| m.has_key? 'backend_system_name' }
    file_product_metric = file_product_metrics[0]
    file_product_methods = file_plan_obj['methods'].reject { |m| m.has_key? 'backend_system_name' }
    file_product_method = file_product_methods[0]
    file_backend_methods = file_plan_obj['methods'].select { |m| m.has_key? 'backend_system_name' }
    file_backend_method = file_backend_methods[0]
    file_backend_metrics = file_plan_obj['metrics'].select { |m| m.has_key? 'backend_system_name' }
    file_backend_metric = file_backend_metrics[0]
    service_metrics = service.metrics
    expect(service_metrics).not_to be_empty
    service_methods = service.methods
    expect(service_methods).not_to be_empty
    service_all_metrics = service_metrics + service_methods

    remote_plan_client = ThreeScaleToolbox::Entities::ApplicationPlan.find(
      service: service, ref: file_plan['system_name']
    )
    expect(remote_plan_client).not_to be_nil

    # check imported plan attrs match plan attr read from remote
    expect(remote_plan_client.attrs).to include(file_plan)

    # check imported plan limts
    remote_limits = remote_plan_client.limits
    expect(remote_limits.size).to eq(2)
    remote_limits.each do |remote_limit|
      if (product_metric = remote_limit.product_metric)
        expect(file_limits).to include({
          'period' => remote_limit.period,
          'value' => remote_limit.value,
          'metric_system_name' => product_metric.system_name
        })
      elsif (product_method = remote_limit.product_method)
        expect(file_limits).to include({
          'period' => remote_limit.period,
          'value' => remote_limit.value,
          'metric_system_name' => product_method.system_name
        })
      elsif (backend_metric = remote_limit.backend_metric)
        expect(file_limits).to include({
          'period' => remote_limit.period,
          'value' => remote_limit.value,
          'metric_system_name' => backend_metric.system_name,
          'metric_backend_system_name' => backend_metric.backend.system_name
        })
      elsif (backend_method = remote_limit.backend_method)
        expect(file_limits).to include({
          'period' => remote_limit.period,
          'value' => remote_limit.value,
          'metric_system_name' => backend_method.system_name,
          'metric_backend_system_name' => backend_method.backend.system_name
        })
      else
        raise "remote limit #{remote_limit} not expected"
      end
    end

    # check import plan pricing rules
    remote_prs = remote_plan_client.pricing_rules
    expect(remote_prs.size).to eq(2)
    remote_prs.each do |remote_pr|
      if (product_metric = remote_pr.product_metric)
        expect(file_pricingrules).to include({
          'cost_per_unit' => remote_pr.cost_per_unit.to_s,
          'min' => remote_pr.min,
          'max' => remote_pr.max,
          'metric_system_name' => product_metric.system_name
        })
      elsif (product_method = remote_pr.product_method)
        expect(file_pricingrules).to include({
          'cost_per_unit' => remote_pr.cost_per_unit.to_s,
          'min' => remote_pr.min,
          'max' => remote_pr.max,
          'metric_system_name' => product_method.system_name
        })
      elsif (backend_metric = remote_pr.backend_metric)
        expect(file_pricingrules).to include({
          'cost_per_unit' => remote_pr.cost_per_unit.to_s,
          'min' => remote_pr.min,
          'max' => remote_pr.max,
          'metric_system_name' => backend_metric.system_name,
          'metric_backend_system_name' => backend_metric.backend.system_name
        })
      elsif (backend_method = remote_pr.backend_method)
        expect(file_pricingrules).to include({
          'cost_per_unit' => remote_pr.cost_per_unit.to_s,
          'min' => remote_pr.min,
          'max' => remote_pr.max,
          'metric_system_name' => backend_method.system_name,
          'metric_backend_system_name' => backend_method.backend.system_name
        })
      else
        raise "remote limit #{remote_limit} not expected"
      end
    end

    # check imported plan features
    remote_plan_features = remote_plan_client.features
    expect(remote_plan_features.size).to eq(1)
    remote_plan_feature = remote_plan_features[0]
    expect(remote_plan_feature).to include(file_feature)

    # check imported methods are subset of service methods
    expect(file_product_methods).to be_subset_of(service_methods.map(&:attrs)).comparing_keys(file_product_method.keys)

    ## check imported metrics are subset of service metrics
    expect(file_product_metrics).to be_subset_of(service_all_metrics.map(&:attrs)).comparing_keys(file_product_metric.keys)

    # check imported backend methods are subset of backend methods
    expect(file_backend_methods).to be_subset_of(backend.methods.map(&:attrs)).comparing_keys(file_backend_method.keys.reject { |k| k == 'backend_system_name' })

    # check imported backend metrics are subset of backend metrics
    expect(file_backend_metrics).to be_subset_of(backend.metrics.map(&:attrs)).comparing_keys(file_backend_metric.keys.reject { |k| k == 'backend_system_name' })
  end
end
