RSpec.describe ThreeScaleToolbox::Tasks::DeleteActiveDocsTask do
  context '#call' do
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:remote) { instance_double('ThreeScale::API::Client', 'remote') }
    subject { described_class.new(target: target) }

    before :each do
      allow(target).to receive(:remote).and_return(remote)
    end

    context 'several activedocs available' do
      let(:n_activedocs) { 10 }
      let(:target_activedocs) do
        Array.new(n_activedocs) { |idx| { 'id' => idx } }
      end

      it 'it calls delete_activedocs method on each activedocs' do
        expect(target).to receive(:activedocs).and_return(target_activedocs)
        expect(target_activedocs.size).to be > 0
        target_activedocs.each do |activedocs|
          expect(remote).to receive(:delete_activedocs).with(activedocs['id'])
        end

        # Run
        subject.call
      end
    end
  end
end
