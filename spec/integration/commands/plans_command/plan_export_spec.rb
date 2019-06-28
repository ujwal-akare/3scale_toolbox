RSpec.describe 'Application Plan Export' do
  include_context :real_api3scale_client
  include_context :temp_dir
  include_context :random_name

  let(:file) { tmp_dir.join('plan.yaml') }
  let(:remote) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end
  let(:service_system_name) { "service_#{random_lowercase_name}" }
  let(:service_obj) { { 'name' => service_system_name, 'system_name' => service_system_name } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_obj
    )
  end
  let(:service_hits_id) { service.hits['id'] }
  # plan system name does not conflict with app plans belonging to other services
  let(:plan_attrs) { { 'name' => 'basic', 'system_name' => 'basic' } }
  let(:plan) do
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
  end
  let(:plan_limit_attrs) { { 'period' => 'year', 'value' => 10_000 } }
  let(:plan_pr_attrs) { { 'cost_per_unit' => 2.0, 'min' => 102, 'max' => 200 } }
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
    method = ThreeScaleToolbox::Entities::Method.create(service: service,
                                                        parent_id: service_hits_id,
                                                        attrs: method_attrs)
    # create more methods not used for limits or pricingrules
    # These methods should not be exported
    ThreeScaleToolbox::Entities::Method.create(service: service, parent_id: service_hits_id,
                                               attrs: { friendly_name: 'method_02' })
    ThreeScaleToolbox::Entities::Method.create(service: service, parent_id: service_hits_id,
                                               attrs: { friendly_name: 'method_03 ' })
    # metric
    metric = ThreeScaleToolbox::Entities::Metric.create(service: service, attrs: metric_attrs)
    # create more metrics not used for limits or pricingrules
    # These metrics should not be exported
    ThreeScaleToolbox::Entities::Metric.create(service: service,
                                               attrs: { unit: '1', friendly_name: 'metric_02' })
    ThreeScaleToolbox::Entities::Metric.create(service: service,
                                               attrs: { unit: '1', friendly_name: 'metric_03' })

    # limit on the metric
    plan.create_limit(metric.attrs.fetch('id'), plan_limit_attrs)

    # pricing rule on the method
    plan.create_pricing_rule(method.attrs.fetch('id'), plan_pr_attrs)

    # Feature
    feature = service.create_feature(plan_feature_attrs)
    plan.create_feature(feature.fetch('id'))
  end

  after :example do
    service.delete
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
