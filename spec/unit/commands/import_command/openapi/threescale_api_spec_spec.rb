require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::ThreeScaleApiSpec do
  include_context :temp_dir

  let(:title) { 'Some Title' }
  let(:description) { 'Some Description' }
  context '#parse' do
    let(:content) do
      <<~YAML
        ---
        swagger: "2.0"
        info:
          title: "#{title}"
          description: "#{description}"
          version: "1.0.0"
        basePath: "/v2"
        paths:
          /pet:
            post:
              operationId: "addPet"
              description: ""
      YAML
    end
    let(:resource) { tmp_dir.join('petstore.yaml').tap { |conf| conf.write(content) } }
    let(:openapi) { Swagger.load(resource, format: :yaml) }
    subject { described_class.parse(openapi) }

    it 'title available' do
      expect(subject.title).to eq(title)
    end

    it 'description available' do
      expect(subject.description).to eq(description)
    end

    it 'operations available' do
      expect(subject.operations).not_to be_nil
    end

    it 'operations parsed as not empty' do
      expect(subject.operations).not_to be_empty
    end

    it 'operations parsed type' do
      expect(subject.operations[0]).to be_a(ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::Operation)
    end
  end
end
