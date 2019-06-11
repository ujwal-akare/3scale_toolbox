RSpec.describe ThreeScaleToolbox::Commands::ApplicationCommand::Delete::DeleteSubcommand do
  let(:arguments) { { application_ref: 'someapp', remote: 'https://key@example.com' } }
  let(:options) {}
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:application_class) { class_double(ThreeScaleToolbox::Entities::Application).as_stubbed_const }
  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    before :example do
      expect(subject).to receive(:threescale_client).and_return(remote)
      expect(application_class).to receive(:find).with(remote: remote, ref: 'someapp')
                                                 .and_return(application)
    end

    context 'when application not found' do
      let(:application) { nil }

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /Application someapp does not exist/)
      end
    end

    context 'when application found' do
      let(:application) { instance_double(ThreeScaleToolbox::Entities::Application) }

      before :example do
        expect(application).to receive(:id).and_return('1')
      end

      it do
        expect(application).to receive(:delete)
        expect { subject.run }.to output(/Application id: 1 deleted/).to_stdout
      end
    end
  end
end
