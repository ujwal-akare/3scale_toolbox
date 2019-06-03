RSpec.describe 'Service List command' do
  include_context :real_api3scale_client
  include_context :random_name
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end

  context "With multiple existing services" do
    let (:svc_ref_1) { "service_sysname_#{random_lowercase_name}" }
    let (:svc_ref_2) { "service_sysname_#{random_lowercase_name}" }
    let (:command_line_str) { "service list #{remote}" }

    before :example do
      ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: { "name" => svc_ref_1 })
      ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: { "name" => svc_ref_2 })
    end

    it "lists svc_ref_1" do
      expect { subject }.to output(/.*#{svc_ref_1}.*/).to_stdout
      expect(subject).to eq(0)
    end

    it "lists svc_ref_2" do
      expect { subject }.to output(/.*#{svc_ref_2}.*/).to_stdout
      expect(subject).to eq(0)
    end

    after :example do
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: svc_ref_1)
      res.delete if !res.nil?
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: svc_ref_2)
      res.delete if !res.nil?
    end
  end
end
