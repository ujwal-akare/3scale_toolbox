RSpec.describe 'Service Create command' do
  include_context :real_api3scale_client
  include_context :random_name
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end

  context 'with the specified service not existing' do
    let (:service_name) { "service_#{random_lowercase_name}" }
    let (:service_ref) { service_name }

    context 'without specifying options' do
      let (:command_line_str) { "service create #{remote} #{service_name}" }

      it "successfully creates a new service" do
        expect(subject).to eq(0)
        res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
        expect(res).not_to be_nil
      end
    end

    context 'specifying options' do
      let (:service_system_name) { "service_sysname_#{random_lowercase_name}" }
      let (:service_ref) { service_system_name }
      let (:service_auth_mode) { "2" }
      let (:options) { "--system-name #{service_system_name} --authentication-mode #{service_auth_mode}" }
      let (:command_line_str) { "service create #{remote} #{service_name} #{options}" }

      it "successfully creates a new service with them" do
        expect(subject).to eq(0)
        res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
        expect(res).not_to be_nil
        expect(res.attrs.fetch("name")).to eq(service_name)
        expect(res.attrs.fetch("system_name")).to eq(service_system_name)
        expect(res.attrs.fetch("backend_version")).to eq(service_auth_mode)
      end
    end

    after :example do
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
      res.delete if !res.nil?
    end
  end

  context 'with the specified service already existing' do
    let (:service_name) { "service_#{random_lowercase_name}" }
    let (:command_line_str) { "service create #{remote} #{service_name}" }

    before :example do
      ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: { "name" => service_name })
    end

    it "fails to create the service" do
      expect(subject).not_to eq(0)
    end

    after :example do
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_name)
      res.delete if !res.nil?
    end
  end
end
