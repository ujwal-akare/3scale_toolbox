RSpec.describe 'ActiveDocs List command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }

  context "With multiple existing activedocs" do
    let(:adocs_ref_1) { "activedocs_sysname_#{random_lowercase_name}" }
    let(:adocs_ref_2) { "activedocs_sysname_#{random_lowercase_name}" }
    let(:service_name) { "service_#{random_lowercase_name}" }
    let(:activedocs_file) { File.join(resources_path, 'valid_swagger.yaml') }
    let(:activedocs_body_pretty_json) do
      activedoc_body_content = YAML.load_file(activedocs_file)
      JSON.pretty_generate(activedoc_body_content)
    end
    let(:command_line_str) { "activedocs list #{remote}" }

    before :example do
      svc = ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: { "name" => service_name })
      ThreeScaleToolbox::Entities::ActiveDocs.create(remote: api3scale_client, attrs: { "name" => adocs_ref_1, "body" => activedocs_body_pretty_json, "service_id" => svc.id},)
      ThreeScaleToolbox::Entities::ActiveDocs.create(remote: api3scale_client, attrs: { "name" => adocs_ref_2, "body" => activedocs_body_pretty_json })
    end

    it "lists adocs_ref_1" do
      expect { subject }.to output(/.*#{adocs_ref_1}.*/).to_stdout
      expect(subject).to eq(0)
    end

    it "lists adocs_ref_2" do
      expect { subject }.to output(/.*#{adocs_ref_2}.*/).to_stdout
      expect(subject).to eq(0)
    end

    context "and filtering by an existing service" do
      let(:command_line_str) { "activedocs list #{remote} --service-ref #{service_name}" }

      it "lists activedocs that match the filter" do
        expect {subject}.to output(/.*#{adocs_ref_1}.*/).to_stdout
        expect(subject).to eq(0)
      end

      it "does nost list activedocs that do not match the filter" do
        expect {subject}.not_to output(/.*#{adocs_ref_2}.*/).to_stdout
        expect(subject).to eq(0)
      end
    end

    after :example do
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: adocs_ref_1)
      res.delete if !res.nil?
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: adocs_ref_2)
      res.delete if !res.nil?
      res = ThreeScaleToolbox::Entities::Service::find(remote: api3scale_client, ref: service_name)
      res.delete if !res.nil?
    end
  end
end
