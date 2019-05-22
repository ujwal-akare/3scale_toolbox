RSpec.describe 'ActiveDocs Apply command' do
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
    let (:activedocs_sysname) { "activedocs_sysname#{random_lowercase_name}" }
    let (:activedocs_ref) { activedocs_sysname }

    context 'without specifying options' do
      let (:command_line_str) { "activedocs apply #{remote} #{activedocs_ref} --openapi-spec #{activedocs_file}" }


      it "successfully creates a new activedocs" do
        expect(subject).to eq(0)
        res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_ref)
        expect(res).not_to be_nil
        expect(res.attrs.fetch("name")).to eq(activedocs_sysname)
        expect(res.attrs.fetch("system_name")).to eq(activedocs_sysname)
        expect(res.attrs.fetch("body")). to eq(activedocs_body_pretty_json)
      end
    end

    context 'specifying options' do
      let (:activedocs_sysname) { "activedocs_sysname#{random_lowercase_name}" }
      let (:activedocs_name) { "activedocs_name#{random_lowercase_name}" }
      let (:activedocs_ref) { activedocs_sysname }
      let (:options) { "--name #{activedocs_name} --publish --openapi-spec #{activedocs_file}"}
      let (:command_line_str) { "activedocs apply #{remote} #{activedocs_ref} #{options}" }

      it "successfully creates a new activedocs with them" do
        expect(subject).to eq(0)
        res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_ref)
        expect(res).not_to be_nil
        expect(res.attrs.fetch("name")).to eq(activedocs_name)
        expect(res.attrs.fetch("system_name")).to eq(activedocs_sysname)
        expect(res.attrs.fetch("published")).to eq(true)
        expect(res.attrs.fetch("body")).to eq(activedocs_body_pretty_json)
      end
    end

    after :example do
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_ref)
      res.delete if !res.nil?
    end
  end

  context 'with the specified activedocs already existing' do
    let (:activedocs_sysname) { "activedocs_sysname#{random_lowercase_name}" }
    let (:activedocs_ref) { activedocs_sysname }

    let (:options) { "--description newdescription --hide" }
    let (:command_line_str) { "activedocs apply #{remote} #{activedocs_ref} #{options}" }
    before :example do
      ThreeScaleToolbox::Entities::ActiveDocs::create(remote: api3scale_client,
        attrs: {"name" => activedocs_ref, "body" => activedocs_body_pretty_json, "published" => true, "description" => "olddescription"} )
    end

    it "is updated" do
      expect(subject).to eq(0)
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_ref)
      expect(res.attrs.fetch("name")).to eq(activedocs_sysname)
      expect(res.attrs.fetch("system_name")).to eq(activedocs_sysname)
      expect(res.attrs.fetch("body")).to eq(activedocs_body_pretty_json)
      expect(res.attrs.fetch("published")).to eq(false)
      expect(res.attrs.fetch("description")).to eq("newdescription")
    end

    after :example do
      res = ThreeScaleToolbox::Entities::ActiveDocs::find(remote: api3scale_client, ref: activedocs_ref)
      res.delete if !res.nil?
    end
  end
end
