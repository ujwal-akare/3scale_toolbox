RSpec.describe 'ActiveDocs List command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }
  
  context "With multiple existing activedocs" do
    let (:adocs_ref_1) { "activedocs_sysname_#{random_lowercase_name}" }
    let (:adocs_ref_2) { "activedocs_sysname_#{random_lowercase_name}" }
    let (:activedocs_file) { File.join(resources_path, 'valid_swagger.yaml') }
    let (:activedocs_body_pretty_json) do
      activedoc_body_content = YAML.load_file(activedocs_file)
      JSON.pretty_generate(activedoc_body_content)
    end
    let (:command_line_str) { "activedocs list #{remote}" }

    before :example do
      ThreeScaleToolbox::Entities::ActiveDocs::create(remote: api3scale_client, attrs: {"name" => adocs_ref_1, "body" => activedocs_body_pretty_json } )
      ThreeScaleToolbox::Entities::ActiveDocs::create(remote: api3scale_client, attrs: {"name" => adocs_ref_2, "body" => activedocs_body_pretty_json } )
    end

    it "lists adocs_ref_1" do
      expect { subject }.to output(/.*#{adocs_ref_1}.*/).to_stdout
      expect(subject).to eq(0)
    end

    it "lists adocs_ref_2" do
      expect { subject }.to output(/.*#{adocs_ref_2}.*/).to_stdout
      expect(subject).to eq(0)
    end

    after :example do
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: adocs_ref_1)
      res.delete if !res.nil?
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: adocs_ref_2)
      res.delete if !res.nil?
    end
  end
end
