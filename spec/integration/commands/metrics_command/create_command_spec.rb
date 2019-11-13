RSpec.describe 'Metric create command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:metric_name) { 'new_name' }
  let(:metric_ref) { 'my_metric_01' }
  let(:metric_descr) { 'SomeDescr' }
  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:command_line_str) do
    "metric create --disabled -t #{metric_ref} --description #{metric_descr}" \
      " #{client_url} #{service_ref} #{metric_name}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_attrs) { { 'name' => 'API 1', 'system_name' => service_ref } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end
  let(:plan_ref) { "app_plan_#{random_lowercase_name}" }

  before :example do
    plan_attrs = { 'name' => 'old_name', 'system_name' => plan_ref }
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
  end

  after :example do
    service.delete
  end

  it 'metric is created and disabled' do
    expect(subject).to eq(0)

    metric = ThreeScaleToolbox::Entities::Metric.find(service: service, ref: metric_ref)
    expect(metric).not_to be_nil
    expect(metric.attrs.fetch('friendly_name')).to eq(metric_name)
    expect(metric.attrs.fetch('description')).to eq(metric_descr)
    plan = ThreeScaleToolbox::Entities::ApplicationPlan.find(service: service, ref: plan_ref)
    expect(plan).not_to be_nil
    # check disabled
    eternity_zero_limits = plan.metric_limits(metric.id).select do |limit|
      limit > { 'period' => 'eternity', 'value' => 0 }
    end
    expect(eternity_zero_limits).not_to be_empty
  end
end
