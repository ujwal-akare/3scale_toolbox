RSpec.describe ThreeScaleToolbox::Commands::ApplicationCommand::List::ListSubcommand do
  let(:arguments) { { remote: 'https://destination_key@destination.example.com' } }
  let(:options) { {} }
  let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
  let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }
  let(:account_class) { class_double(ThreeScaleToolbox::Entities::Account).as_stubbed_const }
  let(:account) { instance_double(ThreeScaleToolbox::Entities::Account) }
  let(:plan_class) { class_double(ThreeScaleToolbox::Entities::ApplicationPlan).as_stubbed_const }
  let(:plan) { instance_double(ThreeScaleToolbox::Entities::ApplicationPlan) }
  let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
  let(:app0) { instance_double(ThreeScaleToolbox::Entities::Application) }
  let(:app1) { instance_double(ThreeScaleToolbox::Entities::Application) }
  let(:app2) { instance_double(ThreeScaleToolbox::Entities::Application) }
  subject { described_class.new(options, arguments, nil) }

  before :example do
    allow(app0).to receive(:attrs).and_return('id' => 'app0_id')
    allow(app1).to receive(:attrs).and_return('id' => 'app1_id')
    allow(app2).to receive(:attrs).and_return('id' => 'app2_id')
  end

  context '#run' do
    context 'account and service passed as options' do
      let(:options) { { account: 'myaccount', service: 'myservice' } }

      it 'invalid options error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /--account and --service are mutually exclusive/)
      end
    end

    context 'account and plan passed as options' do
      let(:options) { { account: 'myaccount', plan: 'myplan' } }

      it 'invalid options error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /--plan requires --service option/)
      end
    end

    context 'only plan passed as options' do
      let(:options) { { plan: 'myplan' } }

      it 'invalid options error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                              /--plan requires --service option/)
      end
    end

    context 'valid options' do
      before :example do
        expect(subject).to receive(:threescale_client).and_return(remote)
      end

      context 'account applications' do
        let(:options) { { account: 'myaccount' } }
        before :example do
          expect(account_class).to receive(:find).with(remote: remote, ref: 'myaccount')
                                                 .and_return(account)
        end

        context 'when app list is returned' do
          let(:application_list) { [app0, app1] }

          before :example do
            expect(account).to receive(:applications).and_return(application_list)
          end

          it 'app_0 in the list' do
            expect { subject.run }.to output(/app0_id/).to_stdout
          end

          it 'app_1 in the list' do
            expect { subject.run }.to output(/app1_id/).to_stdout
          end
        end

        context 'when account not found' do
          let(:account) { nil }

          it 'error raised' do
            expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                  /Account myaccount does not exist/)
          end
        end
      end

      context 'service applications' do
        let(:options) { { service: 'myservice' } }
        before :example do
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(service)
        end

        context 'when app list is returned' do
          let(:application_list) { [app0, app2] }

          before :example do
            expect(service).to receive(:applications).and_return(application_list)
          end

          it 'app_0 in the list' do
            expect { subject.run }.to output(/app0_id/).to_stdout
          end

          it 'app_2 in the list' do
            expect { subject.run }.to output(/app2_id/).to_stdout
          end
        end

        context 'when service not found' do
          let(:service) { nil }

          it 'error raised' do
            expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                  /Service myservice does not exist/)
          end
        end
      end

      context 'plan applications' do
        let(:options) { { service: 'myservice', plan: 'myplan' } }
        before :example do
          expect(service_class).to receive(:find).with(remote: remote, ref: 'myservice')
                                                 .and_return(service)
          expect(plan_class).to receive(:find).with(service: service, ref: 'myplan')
                                              .and_return(plan)
        end

        context 'when app list is returned' do
          let(:application_list) { [app0] }

          before :example do
            expect(plan).to receive(:applications).and_return(application_list)
          end

          it 'app_0 in the list' do
            expect { subject.run }.to output(/app0_id/).to_stdout
          end
        end

        context 'when plan not found' do
          let(:plan) { nil }

          it 'error raised' do
            expect { subject.run }.to raise_error(ThreeScaleToolbox::Error,
                                                  /Application plan myplan does not exist/)
          end
        end
      end

      context 'provider account applications' do
        let(:application_list) { [app0.attrs, app2.attrs] }
        before :example do
          expect(remote).to receive(:list_applications).and_return(application_list)
        end

        it 'app_0 in the list' do
          expect { subject.run }.to output(/app0_id/).to_stdout
        end

        it 'app_2 in the list' do
          expect { subject.run }.to output(/app2_id/).to_stdout
        end
      end
    end
  end
end
