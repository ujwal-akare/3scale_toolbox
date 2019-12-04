RSpec.shared_context :swagger_resources do
  let(:basic_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              405:
                description: "invalid input"
    YAML
  end

  let(:multiple_sec_reqs_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      basePath: "/v1"
      schemes:
        - https
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

  let(:schemes_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      schemes:
        - https
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
    YAML
  end

  let(:host_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      host: "petstore.example.org"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
    YAML
  end
  let(:base_path_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      basePath: "/v1"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
    YAML
  end
  let(:path_extensions_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
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

  let(:parameters_path_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
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

  let(:api_key_sec_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
      security:
        - petstore_api_key: []
      securityDefinitions:
        petstore_api_key:
          type: apiKey
          name: api_key
          in: header
    YAML
  end

  let(:oauth2_implicit_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
      securityDefinitions:
        petstore_oauth:
          type: oauth2
          flow: implicit
          authorizationUrl: http://example.org/api/oauth/dialog
          scopes:
            write:pets: modify pets in your account
            read:pets: read your pets
    YAML
  end

  let(:oauth2_password_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
      securityDefinitions:
        petstore_oauth:
          type: oauth2
          flow: password
          tokenUrl: http://example.org/api/oauth/dialog
          scopes:
            write:pets: modify pets in your account
            read:pets: read your pets
    YAML
  end

  let(:oauth2_application_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
      securityDefinitions:
        petstore_oauth:
          type: oauth2
          flow: application
          tokenUrl: http://example.org/api/oauth/dialog
          scopes:
            write:pets: modify pets in your account
            read:pets: read your pets
    YAML
  end

  let(:oauth2_accessCode_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
      securityDefinitions:
        petstore_oauth:
          type: oauth2
          flow: accessCode
          authorizationUrl: http://example.org/api/oauth/dialog
          tokenUrl: http://example.org/api/oauth/dialog
          scopes:
            write:pets: modify pets in your account
            read:pets: read your pets
    YAML
  end

  let(:basic_sec_swagger_content) do
    <<~YAML
      ---
      swagger: "2.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
      security:
        - petstore_basic: []
      securityDefinitions:
        petstore_basic:
          type: basic
    YAML
  end
end
