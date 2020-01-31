RSpec.describe ThreeScaleToolbox::Commands::ApplicationCommand::Create::CreateSubcommand do
  let(:arguments) do
    {
      remote: 'https://destination_key@destination.example.com',
      account: 'myaccount',
      service: 'myservice',
      plan: 'myplan',
      name: 'myapp'
    }
  end
  let(:options) { {} }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:account_class) { class_double(ThreeScaleToolbox::Entities::Account).as_stubbed_const }
  let(:account) { instance_double(ThreeScaleToolbox::Entities::Account) }
  let(:plan_class) { class_double(ThreeScaleToolbox::Entities::ApplicationPlan).as_stubbed_const }
  let(:plan) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
  let(:application_class) { class_double(ThreeScaleToolbox::Entities::Application).as_stubbed_const }
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:app0_id) { 200 }
  let(:app0_attrs) { { 'id' => app0_id } }
  let(:app0) { instance_double(ThreeScaleToolbox::Entities::Application) }
  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    before :each do
      allow(app0).to receive(:attrs).and_return(app0_attrs)
    end

    context 'when account not found' do
      let(:account) { nil }

      before :example do
        expect(subject).to receive(:threescale_client).and_return(remote)
        expect(account_class).to receive(:find).with(remote: remote, ref: 'myaccount')
                                               .and_return(account)
      end

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Account myaccount does not exist/)
      end
    end

    context 'when service not found' do
      let(:service) { nil }

      before :example do
        expect(subject).to receive(:threescale_client).and_return(remote)
        expect(account_class).to receive(:find).with(remote: remote, ref: 'myaccount')
                                               .and_return(account)
        expect(account).to receive(:id).and_return(1000)
        expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                               .and_return(service)
      end

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Service myservice does not exist/)
      end
    end

    context 'when plan not found' do
      let(:plan) { nil }

      before :example do
        expect(subject).to receive(:threescale_client).and_return(remote)
        expect(account_class).to receive(:find).with(remote: remote, ref: 'myaccount')
                                               .and_return(account)
        expect(account).to receive(:id).and_return(1000)
        expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                               .and_return(service)
        expect(plan_class).to receive(:find).with(service: service, ref: 'myplan')
                                            .and_return(plan)
      end

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /Application plan myplan does not exist/)
      end
    end

    context 'with valid params' do
      before :example do
        expect(subject).to receive(:threescale_client).and_return(remote)
        expect(account_class).to receive(:find).with(remote: remote, ref: 'myaccount')
                                               .and_return(account)
        expect(account).to receive(:id).and_return(1000)
        expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                               .and_return(service)
        expect(plan_class).to receive(:find).with(service: service, ref: 'myplan')
                                            .and_return(plan)
        expect(plan).to receive(:id).and_return(100)
      end

      it 'application belongs to given plan' do
        expect(application_class).to receive(:create).with(hash_including(plan_id: 100))
                                                     .and_return(app0)

        expect { subject.run }.to output(/Created application id: 200/).to_stdout
      end

      it 'application belongs to given account' do
        expect(application_class).to receive(:create).with(hash_including(account_id: 1000))
                                                     .and_return(app0)

        expect { subject.run }.to output(/Created application id: 200/).to_stdout
      end

      context 'without options' do
        let(:options) { {} }
        let(:expected_app_attrs) { { 'name' => 'myapp', 'description' => 'myapp' } }

        it 'description defaults to name' do
          expect(application_class).to receive(:create).with(hash_including(app_attrs: expected_app_attrs))
                                                       .and_return(app0)

          expect { subject.run }.to output(/Created application id: 200/).to_stdout
        end
      end

      context 'redirect-url opt given' do
        let(:options) { { 'redirect-url': 'https://example.com/callback' } }
        let(:expected_app_attrs) do
          {
            'redirect_url' => 'https://example.com/callback', 'name' => 'myapp',
            'description' => 'myapp'
          }
        end

        it 'redirect_url param sent' do
          expect(application_class).to receive(:create).with(hash_including(app_attrs: expected_app_attrs))
                                                       .and_return(app0)

          expect { subject.run }.to output(/Created application id: 200/).to_stdout
        end
      end
    end
  end
end
