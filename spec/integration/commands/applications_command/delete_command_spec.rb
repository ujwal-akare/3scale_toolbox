RSpec.describe 'Application delete command' do
  include_context :real_api3scale_client
  include_context :random_name

  let(:application_id) { random_lowercase_name }
  let(:plan_attrs) { { 'name' => 'some_name', 'system_name' => "app_plan_#{random_lowercase_name}" } }
  let(:plan) do
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: plan_attrs)
  end
  let(:account_name) { "account_#{random_lowercase_name}" }
  let(:account) { api3scale_client.signup(name: account_name, username: account_name) }
  let(:account_ref) { account['id'] }
  let(:command_line_str) { "application delete #{client_url} #{application_id}" }
  let(:command_line_args) { command_line_str.split }
  subject { ThreeScaleToolbox::CLI.run(command_line_args) }
  let(:service_attrs) do
    {
      'name' => 'API 1', 'system_name' => "service_#{random_lowercase_name}",
      'backend_version' => '2'
    }
  end
  let(:service) do
    ThreeScaleToolbox::Entities::Service.create(
      remote: api3scale_client, service_params: service_attrs
    )
  end

  before :example do
    # add application
    app_attrs = {
      'name' => "app_#{random_lowercase_name}",
      'description' => "app #{random_lowercase_name}",
      'application_id' => application_id,
      'application_key' => random_lowercase_name
    }
    ThreeScaleToolbox::Entities::Application.create(remote: api3scale_client,
                                                    account_id: account_ref,
                                                    plan_id: plan.id,
                                                    app_attrs: app_attrs)
  end

  after :example do
    service.delete
    api3scale_client.delete_account(account_ref)
  end

  it 'application is deleted' do
    expect(subject).to eq(0)

    application = ThreeScaleToolbox::Entities::Application.find(remote: api3scale_client,
                                                                service_id: service.id,
                                                                ref: application_id)
    expect(application).to be_nil
  end
end
