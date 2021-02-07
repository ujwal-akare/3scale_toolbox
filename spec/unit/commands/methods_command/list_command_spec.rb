RSpec.describe ThreeScaleToolbox::Commands::MethodsCommand::List::ListSubcommand do
  let(:arguments) do
    {
      service_ref: 'someservice', remote: 'https://destination_key@destination.example.com'
    }
  end
  let(:options) { {} }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double('ThreeScaleToolbox::Entities::Service') }
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:method_0) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:method_0_attrs) { { 'id' => 3, 'friendly_name' => 'method 0' } }
  let(:method_1) { instance_double(ThreeScaleToolbox::Entities::Method) }
  let(:method_1_attrs) { { 'id' => 4, 'friendly_name' => 'method 1' } }

  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    before :example do
      allow(method_0).to receive(:attrs).and_return(method_0_attrs)
      allow(method_1).to receive(:attrs).and_return(method_1_attrs)
      expect(service_class).to receive(:find).and_return(service)
      expect(subject).to receive(:threescale_client).and_return(remote)
    end

    context 'when service not found' do
      let(:service) { nil }

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Service someservice does not exist/)
      end
    end

    context 'when metric list is returned' do
      let(:methods) { [method_0, method_1] }

      before :example do
        expect(service).to receive(:methods).and_return(methods)
      end

      it 'method_0 in the list' do
        expect { subject.run }.to output(/method 0/).to_stdout
      end

      it 'method_1 in the list' do
        expect { subject.run }.to output(/method 1/).to_stdout
      end
    end
  end
end
