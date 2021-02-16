RSpec.describe 'Application Plan create command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:cost_per_month) { 10.23 }
  let(:app_plan_name) { 'new_name' }
  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:plan_ref) { "app_plan_#{random_lowercase_name}" }
  let(:command_line_str) do
    "application-plan create --cost-per-month=#{cost_per_month}" \
      " --publish --disabled -t #{app_plan_name}" \
      " #{client_url} #{service_ref} #{app_plan_name}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_attrs) { { 'name' => 'API 1', 'system_name' => service_ref } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end

  before :example do
    # add method
    method_attrs = { 'system_name' => 'method_01', 'friendly_name' => 'method_01' }
    ThreeScaleToolbox::Entities::Method.create(service: service, attrs: method_attrs)
  end

  after :example do
    service.delete
  end

  it 'application plan is published and enabled' do
    expect(subject).to eq(0)

    plan = ThreeScaleToolbox::Entities::ApplicationPlan.find(service: service, ref: app_plan_name)

    expect(plan).not_to be_nil
    # check name has been changed
    expect(plan.attrs.fetch('name')).to eq(app_plan_name)
    # check published
    expect(plan.published?).to be_truthy
    # check disabled
    zero_eternity_limit_attrs = { 'period' => 'eternity', 'value' => 0 }
    eternity_zero_limits = plan.limits.select { |limit| zero_eternity_limit_attrs < limit.attrs }
    expect(eternity_zero_limits).not_to be_empty
  end
end
