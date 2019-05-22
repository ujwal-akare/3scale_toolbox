RSpec.describe 'ActiveDocs Create command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }
  
  let (:activedocs_file) { File.join(resources_path, 'valid_swagger.yaml') }
  let (:activedocs_body_pretty_json) do
    activedoc_body_content = YAML.load_file(activedocs_file)
    JSON.pretty_generate(activedoc_body_content)
  end

  context 'with the specified activedocs not existing' do
    let (:activedocs_name) { "activedocs_#{random_lowercase_name}" }
    let (:activedocs_ref) { activedocs_name }

    context 'without specifying options' do
      let (:command_line_str) { "activedocs create #{remote} #{activedocs_name} #{activedocs_file}" }

      it "successfully creates a new activedocs" do
        expect(subject).to eq(0)
        res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_ref)
        expect(res).not_to be_nil
        expect(res.attrs.fetch("name")).to eq(activedocs_name)
        expect(res.attrs.fetch("system_name")).to eq(activedocs_name)
        expect(res.attrs.fetch("body")). to eq(activedocs_body_pretty_json)
      end
    end

    context 'specifying options' do
      let (:activedocs_system_name) { "activedocs_sysname_#{random_lowercase_name}" }
      let (:activedocs_ref) { activedocs_system_name }
      let (:options) { "--system-name #{activedocs_system_name} --published"}
      let (:command_line_str) { "activedocs create #{remote} #{activedocs_name} #{activedocs_file} #{options}" }

      it "successfully creates a new activedocs with them" do
        expect(subject).to eq(0)
        res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_ref)
        expect(res).not_to be_nil
        expect(res.attrs.fetch("name")).to eq(activedocs_name)
        expect(res.attrs.fetch("system_name")).to eq(activedocs_system_name)
        expect(res.attrs.fetch("published")).to eq(true)
        expect(res.attrs.fetch("body")). to eq(activedocs_body_pretty_json)
      end
    end

    after :example do
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_ref)
      res.delete if !res.nil?
    end
  end

  context 'with the specified activedocs already existing' do
    let (:activedocs_name) { "activedocs_#{random_lowercase_name}" }
    let (:command_line_str) { "activedocs create #{remote} #{activedocs_name} #{activedocs_file}" }
    before :example do
      ThreeScaleToolbox::Entities::ActiveDocs::create(remote: api3scale_client, attrs: {"name" => activedocs_name, "body" => activedocs_body_pretty_json} )
    end

    it "fails to create the activedocs" do
      expect(subject).not_to eq(0)
    end

    after :example do
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_name)
      res.delete if !res.nil?
    end
  end
end
