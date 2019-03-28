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
      security:
        - OauthSecurity:
          - user
        - MediaSecurity: []
      securityDefinitions:
        OauthSecurity:
          type: oauth2
          flow: accessCode
          authorizationUrl: 'https://oauth.simple.api/authorization'
          tokenUrl: 'https://oauth.simple.api/token'
          scopes:
            admin: Admin scope
            user: User scope
        MediaSecurity:
          type: apiKey
          in: query
          name: media-api-key
        LegacySecurity:
          type: basic
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
        expect { subject }.not_to raise_error
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
        expect { subject }.not_to raise_error
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

    context 'extensions in path object' do
      let(:content) do
        <<~YAML
          ---
          swagger: "2.0"
          info:
            title: "#{title}"
            version: "1.0.0"
          paths:
            /pet:
              get:
                operationId: "getPet"
                responses:
                  200:
                    description: "successful operation"
              x-internal-id: 383883
        YAML
      end
      it 'parsed as not empty' do
        expect(subject.operations).not_to be_empty
      end

      it 'parsed single operation' do
        expect(subject.operations.size).to eq(1)
      end

      it 'parsed operation path /pet' do
        expect(subject.operations[0].path).to eq('/pet')
      end
      it 'parsed operation method get' do
        expect(subject.operations[0].verb).to eq('get')
      end
    end

    context 'parameters in path item object' do
      let(:content) do
        <<~YAML
          ---
          swagger: "2.0"
          info:
            title: "#{title}"
            version: "1.0.0"
          paths:
            /pet/{name}:
              get:
                operationId: "getPet"
                responses:
                  200:
                    description: "successful operation"
              parameters:
                - name: name
                  in: path
                  required: true
                  type: string
        YAML
      end
      it 'parsed as not empty' do
        expect(subject.operations).not_to be_empty
      end

      it 'parsed single operation' do
        expect(subject.operations.size).to eq(1)
      end

      it 'parsed operation path /pet/{name}' do
        expect(subject.operations[0].path).to eq('/pet/{name}')
      end
      it 'parsed operation method get' do
        expect(subject.operations[0].verb).to eq('get')
      end
    end
  end

  context 'global_security_requirements' do
    it 'available' do
      expect(subject.global_security_requirements).not_to be_nil
    end

    it 'parsed as not empty' do
      expect(subject.global_security_requirements).not_to be_empty
    end

    it '2 security schemes parsed' do
      expect(subject.global_security_requirements.size).to eq(2)
    end

    context 'OauthSecurity' do
      let(:sec_scheme) do
        subject.global_security_requirements.find { |sec| sec.id == 'OauthSecurity' }
      end

      it 'available' do
        expect(sec_scheme).not_to be_nil
      end

      it 'type matches' do
        expect(sec_scheme.type).to eq('oauth2')
      end

      it 'name matches' do
        expect(sec_scheme.name).to be_nil
      end

      it 'in_f matches' do
        expect(sec_scheme.in_f).to be_nil
      end

      it 'flow matches' do
        expect(sec_scheme.flow).to eq('accessCode')
      end

      it 'scopes matches' do
        expect(sec_scheme.scopes).to contain_exactly('user')
      end
    end

    context 'MediaSecurity' do
      let(:sec_scheme) do
        subject.global_security_requirements.find { |sec| sec.id == 'MediaSecurity' }
      end

      it 'available' do
        expect(sec_scheme).not_to be_nil
      end

      it 'type matches' do
        expect(sec_scheme.type).to eq('apiKey')
      end

      it 'name matches' do
        expect(sec_scheme.name).to eq('media-api-key')
      end

      it 'in_f matches' do
        expect(sec_scheme.in_f).to eq('query')
      end

      it 'flow matches' do
        expect(sec_scheme.flow).to be_nil
      end

      it 'scopes matches' do
        expect(sec_scheme.scopes).to be_empty
      end
    end

    context 'missing security requirementes' do
      let(:content) do
        <<~YAML
          ---
          swagger: "2.0"
          info:
            title: "#{title}"
            version: "1.0.0"
          basePath: "#{base_path}"
          paths:
            /pet:
              get:
                operationId: "getPet"
                responses:
                  200:
                    description: "successful operation"
          securityDefinitions:
            OauthSecurity:
              type: oauth2
              flow: accessCode
              authorizationUrl: 'https://oauth.simple.api/authorization'
              tokenUrl: 'https://oauth.simple.api/token'
              scopes:
                admin: Admin scope
                user: User scope
            MediaSecurity:
              type: apiKey
              in: query
              name: media-api-key
            LegacySecurity:
              type: basic
        YAML
      end
      it 'available' do
        expect(subject.global_security_requirements).not_to be_nil
      end

      it 'parsed as empty' do
        expect(subject.global_security_requirements).to be_empty
      end
    end

    context 'missing security definitions' do
      let(:content) do
        <<~YAML
          ---
          swagger: "2.0"
          info:
            title: "#{title}"
            version: "1.0.0"
          basePath: "#{base_path}"
          paths:
            /pet:
              get:
                operationId: "getPet"
                responses:
                  200:
                    description: "successful operation"
          security:
            - OauthSecurity:
              - user
            - MediaSecurity: []
        YAML
      end

      it 'parsing raises error' do
        expect { subject.global_security_requirements }.to raise_error(ThreeScaleToolbox::Error, /not found in security definitions/)
      end
    end
  end
end
