RSpec.describe ThreeScaleToolbox::Commands::MethodsCommand::Create::CreateSubcommand do
  let(:arguments) do
    {
      service_ref: 'someservice', remote: 'https://destination_key@destination.example.com',
      method_name: 'some method'
    }
  end
  let(:options) { {} }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:method_class) { class_double(ThreeScaleToolbox::Entities::Method).as_stubbed_const }
  let(:method) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:hits_id) { 1 }
  let(:hits) { { 'id' => hits_id } }
  let(:expected_basic_attrs) { { 'friendly_name' => arguments[:method_name] } }
  let(:method_id) { 1 }
  let(:method_attrs) { { 'id' => method_id } }
  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    before :example do
      expect(subject).to receive(:threescale_client).and_return(remote)
      expect(service_class).to receive(:find).and_return(service)
      allow(method).to receive(:attrs).and_return(method_attrs)
    end

    context 'when service not found' do
      let(:service) { nil }

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Service someservice does not exist/)
      end
    end

    context 'when method is created' do
      let(:expected_attrs) { expected_basic_attrs }
      before :example do
        expect(service).to receive(:hits).and_return(hits)
        expect(method_class).to receive(:create).with(service: service,
                                                      parent_id: hits_id,
                                                      attrs: expected_attrs)
                                                .and_return(method)
      end

      it do
        expect { subject.run }.to output(/Created method id: 1/).to_stdout
      end

      context 'with disable option' do
        let(:options) { { disabled: true } }

        it 'method disabled' do
          expect(method).to receive(:disable)
          expect { subject.run }.to output(/Created method id: 1/).to_stdout
        end
      end

      context 'with other options' do
        let(:options) do
          {
            'system-name': 'a',
            description: 'b'
          }
        end
        let(:expected_attrs) do
          expected_basic_attrs.merge('system_name' => 'a', 'description' => 'b')
        end

        it 'method created with expected params' do
          expect { subject.run }.to output(/Created method id: 1/).to_stdout
        end
      end
    end
  end
end
