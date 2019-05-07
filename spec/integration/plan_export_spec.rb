require '3scale_toolbox'

RSpec.shared_context :plan_export_stubbed_api3scale_client do
  let(:endpoint) { 'https://example.com' }
  let(:provider_key) { '123456789' }
  let(:verify_ssl) { true }
  let(:external_http_client) do
    instance_double('ThreeScale::API::HttpClient', 'external http client')
  end
  let(:api3scale_client) { ThreeScale::API::Client.new(external_http_client) }
  let(:internal_http_client) { instance_double('ThreeScale::API::HttpClient', 'internal http client') }
  let(:http_client_class) { class_double('ThreeScale::API::HttpClient').as_stubbed_const(transfer_nested_constants: true) }

  let(:external_service_id) { 1000 }
  let(:external_service) { { 'service' => { 'id' => external_service_id } } }
  let(:external_hits_metric) { { 'metric' => { 'id' => '1', 'system_name' => 'hits' } } }
  let(:external_service_metrics) { { 'metrics' => [external_hits_metric] } }
  let(:external_method_id) { 2 }
  let(:external_method) { { 'method' => method_attrs.merge('id' => external_method_id) } }
  let(:external_metric_id) { 3 }
  let(:external_metric) { { 'metric' => metric_attrs.merge('id' => external_metric_id) } }
  let(:external_app_plan) { { 'application_plan' => plan_attrs.merge('id' => 1) } }
  let(:external_service_feature) { { 'feature' => plan_feature_attrs.merge('id' => 1) } }
  let(:external_plan_limit) do
    { 'limit' => plan_limit_attrs.merge('metric_id' => external_metric_id) }
  end
  let(:external_plan_pr) do
    { 'pricing_rule' => plan_pr_attrs.merge('metric_id' => external_method_id) }
  end

  let(:internal_service) { external_service }
  let(:internal_app_plan) { external_app_plan }
  let(:internal_plan_limits) { { 'limits' => [external_plan_limit] } }
  let(:internal_plan_pricingrules) { { 'pricing_rules' => [external_plan_pr] } }
  let(:internal_service_metrics) do
    # metrics include methods
    {
      'metrics' => [
        external_hits_metric,
        external_metric,
        { 'metric' => method_attrs.merge('id' => external_method_id) }
      ]
    }
  end
  let(:internal_service_methods) { { 'methods' => [external_method] } }
  let(:internal_plan_features) do
    {
      'features' => [
        { 'feature' => plan_feature_attrs.merge('id' => 1, 'scope' => 'application_plan') }
      ]
    }
  end

  before :example do
    puts '============ RUNNING STUBBED 3SCALE API CLIENTS =========='
    ##
    # Internal http client stub
    expect(http_client_class).to receive(:new).and_return(internal_http_client)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000')
                                                 .and_return(internal_service)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000/application_plans/1')
                                                 .twice.and_return(internal_app_plan)
    expect(internal_http_client).to receive(:get).with('/admin/api/application_plans/1/limits')
                                                 .and_return(internal_plan_limits)
    expect(internal_http_client).to receive(:get).with('/admin/api/application_plans/1/pricing_rules')
                                                 .and_return(internal_plan_pricingrules)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000/metrics')
                                                 .twice.and_return(internal_service_metrics)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/1000/metrics/1/methods')
                                                 .and_return(internal_service_methods)
    expect(internal_http_client).to receive(:get).with('/admin/api/application_plans/1/features')
                                                 .and_return(internal_plan_features)

    ##
    # External http client stub
    allow(external_http_client).to receive(:post).with('/admin/api/services', anything)
                                                 .and_return(external_service)
    allow(external_http_client).to receive(:get).with('/admin/api/services/1000/metrics')
                                                .and_return(external_service_metrics)
    allow(external_http_client).to receive(:post).with('/admin/api/services/1000/metrics/1/methods', anything)
                                                 .and_return(external_method)
    allow(external_http_client).to receive(:post).with('/admin/api/services/1000/metrics', anything)
                                                 .and_return(external_metric)
    allow(external_http_client).to receive(:post).with('/admin/api/services/1000/application_plans', anything)
                                                 .and_return(external_app_plan)
    allow(external_http_client).to receive(:post).with('/admin/api/application_plans/1/metrics/3/limits', anything).and_return({})
    allow(external_http_client).to receive(:post).with('/admin/api/application_plans/1/metrics/2/pricing_rules', anything)
    allow(external_http_client).to receive(:post).with('/admin/api/services/1000/features', anything)
                                                 .and_return(external_service_feature)
    allow(external_http_client).to receive(:post).with('/admin/api/application_plans/1/features', anything)
    allow(external_http_client).to receive(:delete).with('/admin/api/services/1000')
  end
end

RSpec.describe 'Application Plan Export' do
  if ENV.key?('ENDPOINT')
    include_context :real_api3scale_client
  else
    include_context :plan_export_stubbed_api3scale_client
  end
  include_context :temp_dir
  include_context :random_name

  let(:file) { tmp_dir.join('plan.yaml') }
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
  let(:service_hits_id) { service.hits['id'] }
  # plan system name does not conflict with app plans belonging to other services
  let(:plan_attrs) { { 'name' => 'basic', 'system_name' => 'basic' } }
  let(:plan) do
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
  end
  let(:plan_limit_attrs) { { 'period' => 'year', 'value' => 10_000 } }
  let(:plan_pr_attrs) { { 'cost_per_unit' => '2.0', 'min' => 102, 'max' => 200 } }
  let(:plan_feature_attrs) do
    {
      'name' => 'Unlimited Greetings', 'system_name' => 'unlimited_greetings',
      'scope' => 'ApplicationPlan', 'visible' => true
    }
  end
  let(:metric_attrs) do
    {
      'system_name' => 'metric_01', 'friendly_name' => 'metric_01',
      'name' => 'metric_01', 'unit' => '1'
    }
  end
  let(:method_attrs) { { 'system_name' => 'method_01', 'friendly_name' => 'method_01' } }
  let(:command_line_str) do
    "application-plan export -f #{file} #{remote} #{service.id} #{plan.id}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }

  before :example do
    # method
    method = service.create_method(service_hits_id, method_attrs)
    # create more methods not used for limits or pricingrules
    # These methods should not be exported
    service.create_method(service_hits_id, name: 'method_02')
    service.create_method(service_hits_id, name: 'method_03')

    # metric
    metric = service.create_metric(metric_attrs)
    # create more metrics not used for limits or pricingrules
    # These metrics should not be exported
    service.create_metric(name: 'metric_02')
    service.create_metric(name: 'metric_03')

    # limit on the metric
    plan.create_limit(metric.fetch('id'), plan_limit_attrs)

    # pricing rule on the method
    plan.create_pricing_rule(method.fetch('id'), plan_pr_attrs)

    # Feature
    feature = service.create_feature(plan_feature_attrs)
    plan.create_feature(feature.fetch('id'))
  end

  after :example do
    service.delete_service
  end

  it do
    expect(subject).to eq(0)
    deserialized_plan = YAML.safe_load(file.read)

    # check exported plan attrs
    expect(deserialized_plan['plan']).to include(plan_attrs)

    # check exported plan limts
    expect(deserialized_plan['limits'].size).to eq(1)
    expect(deserialized_plan['limits'][0]).to include(plan_limit_attrs)
    expect(deserialized_plan['limits'][0]).to include('metric_system_name' => 'metric_01')

    # check exported plan pricing rules
    expect(deserialized_plan['pricingrules'].size).to eq(1)
    expect(deserialized_plan['pricingrules'][0]).to include(plan_pr_attrs)
    expect(deserialized_plan['pricingrules'][0]).to include('metric_system_name' => 'method_01')

    # check exported plan features
    expect(deserialized_plan['plan_features'].size).to eq(1)
    expect(deserialized_plan['plan_features'][0]).to include(plan_feature_attrs.merge('scope' => 'application_plan'))

    # check exported methods
    expect(deserialized_plan['methods'].size).to eq(1)
    expect(deserialized_plan['methods'][0]).to include(method_attrs)

    # check exported metrics
    expect(deserialized_plan['metrics'].size).to eq(1)
    expect(deserialized_plan['metrics'][0]).to include(metric_attrs)
  end
end
