RSpec.describe 'ActiveDocs Delete command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }

  context 'with the specified activedocs not existing' do
    let (:activedocs_ref) { "activedocs_sysname_#{random_lowercase_name}" }
    let (:command_line_str) { "activedocs delete #{remote} #{activedocs_ref}" }

    it "fails to delete the activedocs" do
      expect(subject).not_to eq(0)
    end
  end

  context 'with an existing activedocs' do
    let (:activedocs_ref) { "activedocs_sysname_#{random_lowercase_name}" }
    let (:command_line_str) { "activedocs delete #{remote} #{activedocs_ref}" }
    let (:activedocs_file) { File.join(resources_path, 'valid_swagger.yaml') }
    let (:activedocs_body_pretty_json) do
      activedoc_body_content = YAML.load_file(activedocs_file)
      JSON.pretty_generate(activedoc_body_content)
    end

    before :example do
      ThreeScaleToolbox::Entities::ActiveDocs::create(remote: api3scale_client, attrs: {"name" => activedocs_ref, "body" => activedocs_body_pretty_json} )
    end

    it "deletes it" do
      expect(subject).to eq(0)
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_ref)
      expect(res).to be_nil
    end
  end
end
