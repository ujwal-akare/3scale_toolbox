RSpec.describe 'Application Plan apply command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:cost_per_month) { 10.23 }
  let(:app_plan_name) { 'new_name' }
  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:plan_ref) { "app_plan_#{random_lowercase_name}" }
  let(:command_line_str) do
    "application-plan apply --cost-per-month=#{cost_per_month} --name=#{app_plan_name}" \
      ' --publish --enabled' \
      " #{client_url} #{service_ref} #{plan_ref}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_attrs) { { 'name' => 'API 1', 'system_name' => service_ref } }
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end
  let(:service_hits_id) { service.hits.fetch('id') }
  let(:plan_attrs) { { 'name' => 'old_name', 'system_name' => plan_ref } }
  let(:plan) do
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
  end

  before :example do
    # Create application plan (hence update will be done)
    # hidden
    plan.update('state' => 'hidden')

    # add method
    method_attrs = { 'system_name' => 'method_01', 'friendly_name' => 'method_01' }
    ThreeScaleToolbox::Entities::Method.create(service: service, parent_id: service_hits_id,
                                               attrs: method_attrs)
    # disabled
    plan.disable
  end

  after :example do
    service.delete
  end

  it 'application plan is published and enabled' do
    expect(subject).to eq(0)

    fresh_plan = ThreeScaleToolbox::Entities::ApplicationPlan.new(id: plan.id, service: service)

    # check name has been changed
    expect(fresh_plan.attrs.fetch('name')).to eq(app_plan_name)
    # check published
    expect(fresh_plan.published?).to be_truthy
    # check enabled
    zero_eternity_limit_attrs = { 'period' => 'eternity', 'value' => 0 }
    eternity_zero_limits = fresh_plan.limits.select { |limit| zero_eternity_limit_attrs < limit }
    expect(eternity_zero_limits).to be_empty
  end
end
