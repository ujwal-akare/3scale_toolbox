require '3scale_toolbox'

RSpec.shared_context :plan_import_stubbed_api3scale_client do
  let(:endpoint) { 'https://example.com' }
  let(:provider_key) { '123456789' }
  let(:verify_ssl) { true }
  let(:external_http_client) { instance_double('ThreeScale::API::HttpClient', 'external http client') }
  let(:api3scale_client) { ThreeScale::API::Client.new(external_http_client) }
  let(:internal_http_client) { instance_double('ThreeScale::API::HttpClient', 'internal http client') }
  let(:http_client_class) { class_double('ThreeScale::API::HttpClient').as_stubbed_const(transfer_nested_constants: true) }
  let(:hits_metric) { { 'metric' => { 'id' => '1', 'system_name' => 'hits' } } }
  let(:metric_01_attrs) do
    {
      'id' => 3, 'system_name' => 'metric_01', 'friendly_name' => 'metric_01',
      'name' => 'metric_01', 'unit' => '1', 'description' => 'Metric01'
    }
  end
  let(:metric_01) { { 'metric' => metric_01_attrs } }
  let(:method_01_attrs) do
    {
      'id' => 2, 'name' => 'method_01', 'system_name' => 'method_01',
      'friendly_name' => 'method_01'
    }
  end
  let(:method_01) { { 'method' => method_01_attrs } }
  let(:limit_01_attrs) { { 'period' => 'year', 'value' => 10_000 } }
  let(:pr_01_attrs) { { 'cost_per_unit' => '2.0', 'min' => 102, 'max' => 200 } }
  let(:feature_01_attrs) do
    {
      'name' => 'Unlimited Greetings', 'system_name' => 'unlimited_greetings',
      'scope' => 'ApplicationPlan', 'visible' => true
    }
  end

  let(:external_service_id) { 1000 }
  let(:external_service) { { 'service' => { 'id' => external_service_id } } }
  let(:external_service_methods) { { 'methods' => [method_01] } }
  let(:external_app_plan) do
    {
      'application_plan' => {
        'id' => 1, 'name' => 'basic', 'system_name' => 'basic',
        'state' => 'published', 'setup_fee' => 0.0, 'cost_per_month' => 0.0,
        'trial_period_days' => 0, 'cancellation_period' => 0, 'approval_required' => false,
        'end_user_required' => false
      }
    }
  end
  let(:external_plan_limits) { { 'limits' => [plan_limit_01] } }
  let(:external_plan_prs) { { 'pricing_rules' => [plan_pr_01] } }
  let(:external_plan_features) do
    {
      'features' => [
        { 'feature' => feature_01_attrs.merge('scope' => 'application_plan', 'id' => 1) }
      ]
    }
  end

  let(:internal_service) { external_service }
  let(:internal_empty_plans) { { 'plans' => [] } }
  let(:internal_app_plan) { { 'application_plan' => { 'id' => 1, 'name' => 'basic', 'system_name' => 'basic' } } }
  let(:internal_plans) { { 'plans' => [internal_app_plan] } }
  let(:internal_initial_service_metrics) { { 'metrics' => [hits_metric] } }
  let(:internal_service_metrics) do
    {
      'metrics' => [
        hits_metric,
        metric_01,
        { 'metric' => method_01_attrs }
      ]
    }
  end
  let(:internal_service_methods) { { 'methods' => [] } }
  let(:plan_limit_01) do
    { 'limit' => limit_01_attrs.merge('metric_id' => metric_01_attrs.fetch('id')) }
  end
  let(:internal_empty_plan_limits) { { 'limits' => [] } }
  let(:plan_pr_01) do
    { 'pricing_rule' => pr_01_attrs.merge('metric_id' => method_01_attrs.fetch('id')) }
  end
  let(:internal_empty_plan_prs) { { 'pricing_rules' => [] } }
  let(:internal_empty_plan_features) { { 'features' => [] } }
  let(:feature_01) { { 'feature' => feature_01_attrs.merge('id' => 1) } }

  before :example do
    puts '============ RUNNING STUBBED 3SCALE API CLIENTS =========='
    ##
    # Internal http client stub
    expect(http_client_class).to receive(:new).and_return(internal_http_client)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000')
                                                 .and_return(internal_service)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000/application_plans/basic')
                                                 .twice.and_raise(ThreeScale::API::HttpClient::NotFoundError)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000/application_plans')
                                                 .and_return(internal_empty_plans, internal_plans)
    expect(internal_http_client).to receive(:post).with('/admin/api/services/1000/application_plans', anything)
                                                  .and_return(internal_app_plan)
    # two calls, with diff return obj
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000/metrics')
                                                 .and_return(internal_initial_service_metrics,
                                                             internal_service_metrics,
                                                             internal_service_metrics)
    expect(internal_http_client).to receive(:post).with('/admin/api/services/1000/metrics', anything)
                                                  .and_return(metric_01)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000/metrics/1/methods')
                                                 .and_return(internal_service_methods)
    expect(internal_http_client).to receive(:post).with('/admin/api/services/1000/metrics/1/methods', anything)
                                                  .and_return(method_01)
    expect(internal_http_client).to receive(:get).with('/admin/api/application_plans/1/limits')
                                                 .and_return(internal_empty_plan_limits)
    expect(internal_http_client).to receive(:post).with('/admin/api/application_plans/1/metrics/3/limits', anything)
                                                  .and_return(plan_limit_01)
    expect(internal_http_client).to receive(:get).with('/admin/api/application_plans/1/pricing_rules')
                                                 .and_return(internal_empty_plan_prs)
    expect(internal_http_client).to receive(:post).with('/admin/api/application_plans/1/metrics/2/pricing_rules', anything)
                                                  .and_return(plan_pr_01)
    expect(internal_http_client).to receive(:get).with('/admin/api/application_plans/1/features')
                                                 .and_return(internal_empty_plan_features)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000/features')
                                                 .and_return(internal_empty_plan_features)
    expect(internal_http_client).to receive(:post).with('/admin/api/services/1000/features', anything)
                                                  .and_return(feature_01)
    expect(internal_http_client).to receive(:post).with('/admin/api/application_plans/1/features', anything)
                                                  .and_return(feature_01)

    ##
    # External http client stub
    allow(external_http_client).to receive(:post).with('/admin/api/services', anything)
                                                 .and_return(external_service)
    allow(external_http_client).to receive(:delete).with('/admin/api/services/1000')
    allow(external_http_client).to receive(:get).with('/admin/api/services/1000/metrics')
                                                .and_return(internal_service_metrics)
    allow(external_http_client).to receive(:get).with('/admin/api/services/1000/metrics/1/methods')
                                                .and_return(external_service_methods)
    allow(external_http_client).to receive(:get).with('/admin/api/services/1000/application_plans/basic')
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError)
    allow(external_http_client).to receive(:get).with('/admin/api/services/1000/application_plans')
                                                .and_return(internal_plans)
    allow(external_http_client).to receive(:get).with('/admin/api/services/1000/application_plans/1')
                                                .and_return(external_app_plan)
    allow(external_http_client).to receive(:get).with('/admin/api/application_plans/1/limits')
                                                .and_return(external_plan_limits)
    allow(external_http_client).to receive(:get).with('/admin/api/application_plans/1/pricing_rules')
                                                .and_return(external_plan_prs)
    allow(external_http_client).to receive(:get).with('/admin/api/application_plans/1/features')
                                                .and_return(external_plan_features)
  end
end

RSpec.describe 'Application Plan Import' do
  if ENV.key?('ENDPOINT')
    include_context :real_api3scale_client
  else
    include_context :plan_import_stubbed_api3scale_client
  end
  include_context :resources
  include_context :random_name

  let(:file) { File.join(resources_path, 'plan.yaml') }
  let(:remote) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end
  let(:service_system_name) { "service_#{random_lowercase_name}" }
  let(:service_obj) { { 'name' => service_system_name } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service: service_obj, system_name: service_system_name
    )
  end

  # plan system name does not conflict with app plans belonging to other services
  let(:command_line_str) do
    "application-plan import -f #{file} #{remote} #{service.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }

  after :example do
    service.delete_service
  end

  it do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    file_plan_obj = YAML.safe_load(File.read(file))
    file_plan = file_plan_obj['plan']
    file_limits = file_plan_obj['limits']
    file_limit = file_limits[0]
    file_pricingrules = file_plan_obj['pricingrules']
    file_pricingrule = file_pricingrules[0]
    file_features = file_plan_obj['plan_features']
    file_feature = file_features[0]
    file_metrics = file_plan_obj['metrics']
    file_metric = file_metrics[0]
    file_methods = file_plan_obj['methods']
    file_method = file_methods[0]
    service_metrics = service.metrics
    expect(service_metrics).not_to be_empty
    service_methods = service.methods
    expect(service_methods).not_to be_empty
    remote_plan_client = ThreeScaleToolbox::Entities::ApplicationPlan.find(
      service: service, ref: file_plan['system_name']
    )
    expect(remote_plan_client).not_to be_nil

    # check imported plan attrs match plan attr read from remote
    expect(remote_plan_client.show).to include(file_plan)

    # check imported plan limts
    remote_plan_limits = remote_plan_client.limits
    expect(remote_plan_limits.size).to eq(1)
    remote_plan_limit = remote_plan_limits[0]
    ## compare limit read from remote and limit read from file
    expect(remote_plan_limit).to include(file_limit.clone.tap { |h| h.delete('metric_system_name') })
    ## check metric_id refer to a metric with metric_system_name from file limit
    limit_metric = service_metrics.find do |m|
      m.fetch('id') == remote_plan_limit.fetch('metric_id')
    end
    expect(limit_metric).not_to be_nil
    expect(limit_metric['system_name']).to eq(file_limit.fetch('metric_system_name'))

    # check import plan pricing rules
    remote_plan_prs = remote_plan_client.pricing_rules
    expect(remote_plan_prs.size).to eq(1)
    remote_plan_pr = remote_plan_prs[0]
    ## compare pricing rule read from remote and pricing rule read from file
    expect(remote_plan_pr).to include(file_pricingrule.clone.tap { |h| h.delete('metric_system_name') })
    ## check metric_id refer to a metric with metric_system_name from file pricing rule
    pr_metric = service_metrics.find do |m|
      m.fetch('id') == remote_plan_pr.fetch('metric_id')
    end
    expect(pr_metric).not_to be_nil
    expect(pr_metric['system_name']).to eq(file_pricingrule.fetch('metric_system_name'))

    # check imported plan features
    remote_plan_features = remote_plan_client.features
    expect(remote_plan_features.size).to eq(1)
    remote_plan_feature = remote_plan_features[0]
    expect(remote_plan_feature).to include(file_feature)

    # check imported methods are subset of service methods
    expect(file_methods).to be_subset_of(service_methods).comparing_keys(file_method.keys)

    ## check imported metrics are subset of service metrics
    expect(file_metrics).to be_subset_of(service_metrics).comparing_keys(file_metric.keys)
  end
end
