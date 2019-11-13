RSpec.describe 'Application Plan delete command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:plan_ref) { "app_plan_#{random_lowercase_name}" }
  let(:command_line_str) do
    'application-plan delete' \
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
  let(:plan_attrs) { { 'name' => 'old_name', 'system_name' => plan_ref } }

  before :example do
    # Create application plan (hence update will be done)
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
  end

  after :example do
    service.delete
  end

  it 'application plan is deleted' do
    expect(subject).to eq(0)

    expect(ThreeScaleToolbox::Entities::ApplicationPlan.find(service: service, ref: plan_ref)).to be_nil
  end
end
