RSpec.describe ThreeScaleToolbox::Commands::PolicyRegistryCommand::Copy::CopySubcommand do
  let(:arguments) { { source_remote: 'source_remote', target_remote: 'target_remote' } }
  let(:options) { {} }
  let(:source_remote) { instance_double('ThreeScale::API::Client', 'source_remote') }
  let(:target_remote) { instance_double('ThreeScale::API::Client', 'target_remote') }
  subject { described_class.new(options, arguments, nil) }

  context '#run' do
    context 'source policy registry list returns error' do
      let(:list_error) { { 'errors' => 'some error happened' } }

      before :example do
        expect(subject).to receive(:threescale_client).with('source_remote').and_return(source_remote)
        expect(source_remote).to receive(:list_policy_registry).and_return(list_error)
      end

      it 'then error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /source/)
      end
    end

    context 'target policy registry list returns error' do
      let(:list_error) { { 'errors' => 'some error happened' } }

      before :example do
        expect(subject).to receive(:threescale_client).with('source_remote').and_return(source_remote)
        expect(subject).to receive(:threescale_client).with('target_remote').and_return(target_remote)
        expect(source_remote).to receive(:list_policy_registry).and_return([])
        expect(target_remote).to receive(:list_policy_registry).and_return(list_error)
      end

      it 'then error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /target/)
      end
    end

    context 'some missing policies' do
      let(:source_policies) do
        [
          { 'name' => 'p1', 'version' => '0.0.1' },
          { 'name' => 'p2', 'version' => '0.0.1' },
          { 'name' => 'p3', 'version' => '0.0.1' }
        ]
      end
      before :example do
        expect(subject).to receive(:threescale_client).with('source_remote').and_return(source_remote)
        expect(subject).to receive(:threescale_client).with('target_remote').and_return(target_remote)
        expect(source_remote).to receive(:list_policy_registry).and_return(source_policies)
        expect(target_remote).to receive(:list_policy_registry).and_return([])
      end

      it 'are created in target account' do
        source_policies.each do |policy|
          expect(target_remote).to receive(:create_policy_registry).with(policy).and_return({})
        end
        expect { subject.run }.to output(/Created #{source_policies.size} missing policies/).to_stdout
      end
    end

    context 'some matching policies' do
      let(:source_policies) do
        [
          { 'name' => 'p1', 'version' => '0.0.1', 'newparam' => 'new_value' }
        ]
      end
      let(:target_policies) do
        [
          { 'name' => 'p1', 'version' => '0.0.1' },
          { 'name' => 'p98', 'version' => '0.0.1' },
          { 'name' => 'p99', 'version' => '0.0.1' }
        ]
      end
      before :example do
        expect(subject).to receive(:threescale_client).with('source_remote').and_return(source_remote)
        expect(subject).to receive(:threescale_client).with('target_remote').and_return(target_remote)
        expect(source_remote).to receive(:list_policy_registry).and_return(source_policies)
        expect(target_remote).to receive(:list_policy_registry).and_return(target_policies)
      end

      it 'are updated in target account' do
        expect(target_remote).to receive(:update_policy_registry).with('p1-0.0.1', source_policies[0]).and_return({})
        expect { subject.run }.to output(/Updated #{source_policies.size} matching policies/).to_stdout
      end
    end
  end
end
