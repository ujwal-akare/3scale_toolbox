RSpec.describe 'Service Apply command' do
  include_context :real_api3scale_client
  include_context :random_name
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end

  context "When service not exists" do
    let (:service_ref) { "service_sysname_#{random_lowercase_name}" }
    let (:command_line_str) { "service apply #{remote} #{service_ref}" }

    it "is created" do
      expect(subject).to eq(0)
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
      expect(res).not_to be_nil
    end

    context "and options are specified" do
      let (:service_name) { "service_#{random_lowercase_name}" }
      let (:service_auth_mode) { "1" }
      let (:support_email) { "examplesupport@gmail.com" }
      let (:options) { "--name #{service_name} --authentication-mode #{service_auth_mode} --support-email #{support_email}" }
      let (:command_line_str) { "service apply #{remote} #{service_ref} #{options}" }

      it "is created with those options set" do
        expect(subject).to eq(0)
        res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
        expect(res).not_to be_nil
        expect(res.attrs.fetch("system_name")).to eq(service_ref)
        expect(res.attrs.fetch("name")).to eq(service_name)
        expect(res.attrs.fetch("support_email")).to eq(support_email)
        expect(res.attrs.fetch("backend_version")).to eq(service_auth_mode)
      end
    end

    after :example do
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
      res.delete if !res.nil?
    end
  end

  context "When service exists" do
    let (:service_ref) { "service_sysname_#{random_lowercase_name}" }
    let (:service_new_name) { "service_name_#{random_lowercase_name}" }
    let (:service_new_desc) { "anewdescription" }
    let (:service_new_mail) { "newmail@gmail.com" }
    let (:options) { "--name #{service_new_name} --description #{service_new_desc} --support-email #{service_new_mail}" }
    let (:command_line_str) { "service apply #{remote} #{service_ref} #{options}" }

    before :example do
      service_params = {
        "name" => "oldname",
        "system_name" => service_ref,
        "description" => "olddescription",
        "support_email" => "oldsupmail@gmail.com",
      }
      ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: service_params)
    end

    it "is updated" do
      expect(subject).to eq(0)
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
      expect(res).not_to be_nil
      expect(res.attrs.fetch("system_name")).to eq(service_ref)
      expect(res.attrs.fetch("name")).to eq(service_new_name)
      expect(res.attrs.fetch("description")).to eq(service_new_desc)
      expect(res.attrs.fetch("support_email")).to eq(service_new_mail)
    end

    after :example do
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_ref)
      res.delete if !res.nil?
    end
  end
end
