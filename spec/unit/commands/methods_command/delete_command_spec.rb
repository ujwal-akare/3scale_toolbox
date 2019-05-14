RSpec.describe ThreeScaleToolbox::Commands::MethodsCommand::Delete::DeleteSubcommand do
  let(:arguments) do
    {
      method_ref: 'somemethod', service_ref: 'someservice',
      remote: 'https://destination_key@destination.example.com'
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
  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    before :example do
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

    context 'when method not found' do
      before :example do
        expect(service).to receive(:hits).and_return(hits)
        expect(method_class).to receive(:find).with(service: service,
                                                    parent_id: hits_id,
                                                    ref: arguments[:method_ref]).and_return(nil)
      end

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Method somemethod does not exist/)
      end
    end

    context 'when method found' do
      before :example do
        expect(service).to receive(:hits).and_return(hits)
        expect(method_class).to receive(:find).with(service: service,
                                                    parent_id: hits_id,
                                                    ref: arguments[:method_ref])
                                              .and_return(method)
        expect(method).to receive(:id).and_return('1')
      end

      it do
        expect(method).to receive(:delete)
        expect { subject.run }.to output(/Method id: 1 deleted/).to_stdout
      end
    end
  end
end
