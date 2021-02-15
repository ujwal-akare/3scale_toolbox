RSpec.describe ThreeScaleToolbox::Commands::UpdateCommand::ServiceCommand::DeleteActiveDocsTask do
  context '#call' do
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
    let(:activedocs0) { instance_double(ThreeScaleToolbox::Entities::ActiveDocs, 'activedocs0') }
    let(:activedocs1) { instance_double(ThreeScaleToolbox::Entities::ActiveDocs, 'activedocs1') }
    let(:activedocs2) { instance_double(ThreeScaleToolbox::Entities::ActiveDocs, 'activedocs2') }
    let(:target_activedocs) { [activedocs0, activedocs1, activedocs2] }
    subject { described_class.new(target: target) }

    before :each do
      allow(target).to receive(:remote).and_return(remote)
      expect(target).to receive(:activedocs).and_return(target_activedocs)
    end

    context 'several activedocs available' do

      it 'it calls delete method on each activedocs' do
        target_activedocs.each { |activedocs| expect(activedocs).to receive(:delete) }
        # Run
        subject.call
      end
    end
  end
end
