RSpec.describe 'Service Delete command' do
  include_context :real_api3scale_client
  include_context :random_name
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end

  context 'with the specified service not existing' do
    let (:service_ref) { "service_sysname_#{random_lowercase_name}" }
    let (:command_line_str) { "service delete #{remote} #{service_ref}" }

    it "fails to delete the service" do
      expect(subject).not_to eq(0)
    end
  end

  context 'with an existing service' do
    let (:service_ref) { "service_sysname_#{random_lowercase_name}" }
    let (:command_line_str) { "service delete #{remote} #{service_ref}" }
    before :example do
      ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: {"name" => service_ref} )
    end

    it "deletes it" do
      expect(subject).to eq(0)
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
      expect(res).to be_nil
    end
  end
end
