RSpec.describe ThreeScaleToolbox::Commands::ImportCommand::OpenAPI::CreateActiveDocsStep do
  let(:api_spec_resource) { double('api_spec_resource') }
  let(:api_spec) { double('api_spec') }
  let(:service) { double('service') }
  let(:threescale_client) { double('threescale_client') }
  let(:published) { true }
  let(:openapi_context) do
    {
      api_spec_resource: api_spec_resource,
      target: service,
      api_spec: api_spec,
      threescale_client: threescale_client,
      activedocs_published: published
    }
  end
  let(:title) { 'Some Title' }
  let(:description) { 'Some Description' }
  let(:oas_body) { '{}' }
  let(:service_id) { 1 }
  let(:service_system_name) { 'some_system_name' }
  let(:activedocs_list) do
    [
      { 'id' => 1, 'system_name' => 'one' },
      { 'id' => 2, 'system_name' => service_system_name },
      { 'id' => 3, 'system_name' => 'other' }
    ]
  end
  let(:service_attrs) { { 'id' => service_id, 'system_name' => service_system_name } }

  subject { described_class.new(openapi_context) }

  context '#call' do
    before :each do
      allow(api_spec).to receive(:title).and_return(title)
      allow(api_spec).to receive(:description).and_return(description)
      allow(service).to receive(:id).and_return(service_id)
      allow(service).to receive(:show_service).and_return(service_attrs)
      allow(api_spec_resource).to receive(:to_json).and_return(oas_body)
    end

    context 'creates activedocs' do
      it 'with name as title' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(name: title)).and_return({})
        subject.call
      end

      it 'with description as api_spec.description' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(description: description)).and_return({})
        subject.call
      end

      it 'with service_id' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(service_id: service_id)).and_return({})
        subject.call
      end

      it 'with system name' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(system_name: service_system_name)).and_return({})
        subject.call
      end

      it 'with body' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(body: oas_body)).and_return({})
        subject.call
      end

      it 'with published flag as true' do
        expect(threescale_client).to receive(:create_activedocs)
          .with(hash_including(published: true)).and_return({})
        subject.call
      end

      context 'context published is false' do
        let(:published) { false }
        it 'with published flag as false' do
          expect(threescale_client).to receive(:create_activedocs)
            .with(hash_including(published: false)).and_return({})
          subject.call
        end
      end
    end

    context 'creates activedocs and returns error' do
      before :each do
        expect(threescale_client).to receive(:create_activedocs)
          .and_return('errors' => { 'system_name' => ['some error ocurred'] })
      end

      it 'then raises error' do
        expect { subject.call }.to raise_error(ThreeScaleToolbox::Error, /some error ocurred/)
      end
    end

    context 'when activedocs already exists' do
      before :each do
        expect(threescale_client).to receive(:create_activedocs)
          .and_return('errors' => {'system_name' => ['has already been taken']})
        expect(threescale_client).to receive(:list_activedocs)
          .and_return(activedocs_list)
      end

      it 'then updates activedocs with expected id' do
        expect(threescale_client).to receive(:update_activedocs).with(2, anything).and_return({})
        expect { subject.call }.to output.to_stdout
      end
    end
  end
end
