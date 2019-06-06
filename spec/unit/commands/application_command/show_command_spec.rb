RSpec.describe ThreeScaleToolbox::Commands::ApplicationCommand::Show::ShowSubcommand do
  let(:arguments) { { application: 'someapp', remote: 'https://key@destination.example.com' } }
  let(:options) {}
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:application_class) { class_double(ThreeScaleToolbox::Entities::Application).as_stubbed_const }
  let(:application) { instance_double(ThreeScaleToolbox::Entities::Application) }
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
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Application someapp does not exist/)
      end
    end

    context 'when application is found' do
      let(:app_attrs) { { 'id' => 'appId', 'name' => 'appA' } }
      before :example do
        expect(application).to receive(:attrs).and_return(app_attrs)
      end

      it 'id is shown' do
        expect { subject.run }.to output(/appId/).to_stdout
      end

      it 'name is shown' do
        expect { subject.run }.to output(/appA/).to_stdout
      end
    end
  end
end
