RSpec.describe 'Method create command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:method_name) { 'new_name' }
  let(:method_ref) { 'my_method_01' }
  let(:method_descr) { 'SomeDescr' }
  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:command_line_str) do
    "method create --disabled -t #{method_ref} --description #{method_descr}" \
      " #{client_url} #{service_ref} #{method_name}"
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

  it 'method is created and disabled' do
    expect(subject).to eq(0)

    method = ThreeScaleToolbox::Entities::Method.find(service: service, ref: method_ref)
    expect(method).not_to be_nil
    expect(method.attrs.fetch('friendly_name')).to eq(method_name)
    expect(method.attrs.fetch('description')).to eq(method_descr)
    plan = ThreeScaleToolbox::Entities::ApplicationPlan.find(service: service, ref: plan_ref)
    expect(plan).not_to be_nil
    # check disabled
    eternity_zero_limits = plan.metric_limits(method.id).select do |limit|
      limit > { 'period' => 'eternity', 'value' => 0 }
    end
    expect(eternity_zero_limits).not_to be_empty
  end
end
