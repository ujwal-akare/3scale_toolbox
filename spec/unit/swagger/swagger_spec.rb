require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Swagger do
  let(:raw_specification) { YAML.safe_load(content) }
  let(:validate) { true }
  subject { described_class.build(raw_specification, validate: validate) }
  let(:title) { 'some info title' }
  let(:description) { 'some info description' }
  let(:base_path) { '/v2' }
  let(:content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "#{title}"
        description: "#{description}"
        version: "1.0.0"
      basePath: "#{base_path}"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
        /pet/findByStatus:
          get:
            operationId: "findPetsByStatus"
            responses:
              200:
                description: "successful operation"
    YAML
  end

  context 'missing info' do
    let(:content) do
      <<~YAML
        ---
        swagger: "2.0"
        paths:
          /pet:
            post:
              operationId: "addPet"
              description: ""
      YAML
    end

    it 'should raise error' do
      expect { subject }.to raise_error(JSON::Schema::ValidationError)
    end

    context 'but when validation skipped' do
      let(:validate) { false }

      it 'should not raise error' do
        expect { subject }.not_to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  context 'missing paths' do
    let(:content) do
      <<~YAML
        ---
        swagger: "2.0"
        info:
          title: "sometitle"
          description: "some description"
          version: "1.0.0"
      YAML
    end

    it 'should raise error' do
      expect { subject }.to raise_error(JSON::Schema::ValidationError)
    end

    context 'but when validation skipped' do
      let(:validate) { false }

      it 'should not raise error' do
        expect { subject }.not_to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  context 'base_path' do
    it 'available' do
      expect(subject.base_path).to eq(base_path)
    end

    context 'missing' do
      let(:content) do
        <<~YAML
          ---
          swagger: "2.0"
          info:
            title: "some title"
            version: "1.0.0"
          paths:
            /pet:
              post:
                responses:
                  200:
                    description: "successful operation"
        YAML
      end
      it 'should return nil' do
        expect(subject.base_path).to be_nil
      end
    end
  end

  context 'info' do
    it 'title available' do
      expect(subject.info.title).to eq(title)
    end

    it 'description available' do
      expect(subject.info.description).to eq(description)
    end
  end

  context 'operations' do
    it 'available' do
      expect(subject.operations).not_to be_nil
    end

    it 'parsed as not empty' do
      expect(subject.operations).not_to be_empty
    end

    context 'get pet' do
      let(:get_pet_operation) do
        subject.operations.find { |op| op.path == '/pet' && op.verb == 'get' }
      end

      it 'available' do
        expect(get_pet_operation).not_to be_nil
      end

      it 'operationId matches' do
        expect(get_pet_operation.operation_id).to eq('getPet')
      end
    end

    context 'post pet' do
      let(:post_pet_operation) do
        subject.operations.find { |op| op.path == '/pet' && op.verb == 'post' }
      end

      it 'available' do
        expect(post_pet_operation).not_to be_nil
      end

      it 'operationId matches' do
        expect(post_pet_operation.operation_id).to eq('addPet')
      end
    end

    context 'get findPetsByStatus' do
      let(:get_findPetsByStatus_operation) do
        subject.operations.find { |op| op.path == '/pet/findByStatus' && op.verb == 'get' }
      end

      it 'available' do
        expect(get_findPetsByStatus_operation).not_to be_nil
      end

      it 'operationId matches' do
        expect(get_findPetsByStatus_operation.operation_id).to eq('findPetsByStatus')
      end
    end
  end
end
