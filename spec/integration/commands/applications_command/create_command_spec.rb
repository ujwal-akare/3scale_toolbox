RSpec.describe 'Applications create command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:service_ref) { "service_#{random_lowercase_name}" }
  let(:application_id) { random_lowercase_name }
  let(:application_key) { random_lowercase_name }
  let(:app_name) { "app_#{random_lowercase_name}" }
  let(:app_descr) { 'SomeApplication' }
  let(:plan_ref) { "app_plan_#{random_lowercase_name}" }
  let(:account_name) { "account_#{random_lowercase_name}" }
  let(:account) { api3scale_client.signup(name: account_name, username: account_name) }
  let(:account_ref) { account['id'] }
  let(:command_line_str) do
    "application create --description #{app_descr}" \
      " --application-id #{application_id}" \
      " --application-key #{application_key}" \
      " #{client_url} #{account_ref} #{service_ref} #{plan_ref} #{app_name}"
  end
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_attrs) do
    {
      'name' => 'API 1', 'system_name' => service_ref, 'backend_version' => '2'
    }
  end
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end

  before :example do
    plan_attrs = { 'name' => 'old_name', 'system_name' => plan_ref }
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
  end

  after :example do
    service.delete
    api3scale_client.delete_account(account['id'])
  end

  it 'application is created' do
    expect(subject).to eq(0)

    application = ThreeScaleToolbox::Entities::Application.find(remote: api3scale_client,
                                                                service_id: service.id,
                                                                ref: application_id)
    expect(application).not_to be_nil
  end
end
