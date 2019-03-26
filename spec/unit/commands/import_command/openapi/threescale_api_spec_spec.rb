require '3scale_toolbox'

RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::ThreeScaleApiSpec do
  let(:title) { 'Some Title' }
  let(:description) { 'Some Description' }
  let(:content) do
    <<~YAML
        ---
        swagger: "2.0"
        info:
          title: "#{title}"
          description: "#{description}"
          version: "1.0.0"
        basePath: "/v2"
        schemes: ["https", "http"]
        paths:
          /pet:
            post:
              operationId: "addPet"
              description: ""
              responses:
                405:
                  description: "invalid input"
        security:
          - OauthSecurity:
            - user
        securityDefinitions:
          OauthSecurity:
            type: oauth2
            flow: accessCode
            authorizationUrl: 'https://oauth.simple.api/authorization'
            tokenUrl: 'https://oauth.simple.api/token'
            scopes:
              admin: Admin scope
              user: User scope
    YAML
  end
  let(:minimum_req_swagger) do
    <<~YAML
        ---
        swagger: "2.0"
        info:
          title: "#{title}"
          version: "1.0.0"
        paths:
          /pet:
            post:
              operationId: "addPet"
              responses:
                405:
                  description: "invalid input"
    YAML
  end
  let(:openapi) { ThreeScaleToolbox::Swagger.build(YAML.safe_load(content)) }
  subject { described_class.new(openapi) }

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

  context '#schemes' do
    it 'schemes match' do
      expect(subject.schemes).to match_array(%w[https http])
    end

    context 'missing schemes field' do
      let(:content) { minimum_req_swagger }

      it 'empty array match' do
        expect(subject.schemes).to match_array([])
      end
    end
  end
  context '#backend_version' do
    it 'matches oidc version' do
      expect(subject.backend_version).to eq('oidc')
    end

    context 'missing security reqs' do
      let(:content) { minimum_req_swagger }

      it 'matches apiKey version' do
        expect(subject.backend_version).to eq('1')
      end
    end

    context 'apiKey security reqs' do
      let(:content) do
        <<~YAML
          ---
          swagger: "2.0"
          info:
            title: "#{title}"
            version: "1.0.0"
          paths:
            /pet:
              post:
                operationId: "addPet"
                responses:
                  405:
                    description: "invalid input"
          security:
            - MediaSecurity: []
          securityDefinitions:
            MediaSecurity:
              type: apiKey
              in: query
              name: media-api-key
        YAML
      end

      it 'matches apiKey version' do
        expect(subject.backend_version).to eq('1')
      end
    end

    context 'basic security reqs' do
      let(:content) do
        <<~YAML
          ---
          swagger: "2.0"
          info:
            title: "#{title}"
            version: "1.0.0"
          paths:
            /pet:
              post:
                operationId: "addPet"
                responses:
                  405:
                    description: "invalid input"
          security:
            - LegacySecurity: []
          securityDefinitions:
            LegacySecurity:
              type: basic
        YAML
      end

      it 'raises error' do
        expect { subject.backend_version }.to raise_error(ThreeScaleToolbox::Error, /security scheme type/)
      end
    end
  end

  context '#security' do
    it 'not nil' do
      expect(subject.security).not_to be_nil
    end

    context 'multiple security requirements' do
      let(:content) do
        <<~YAML
          ---
          swagger: "2.0"
          info:
            title: "#{title}"
            version: "1.0.0"
          paths:
            /pet:
              post:
                operationId: "addPet"
                responses:
                  405:
                    description: "invalid input"
          security:
            - MediaSecurity: []
            - LegacySecurity: []
          securityDefinitions:
            MediaSecurity:
              type: apiKey
              in: query
              name: media-api-key
            LegacySecurity:
              type: basic
        YAML
      end

      it 'raises error' do
        expect { subject.security }.to raise_error(ThreeScaleToolbox::Error, /multiple security/)
      end
    end
  end
end
