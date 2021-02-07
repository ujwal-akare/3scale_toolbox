RSpec.describe ThreeScaleToolbox::Commands::ServiceCommand::CopyCommand::DestroyMappingRulesTask do
  context '#call' do
    let(:target) { instance_double('ThreeScaleToolbox::Entities::Service', 'target') }
    let(:context) { { target: target } }
    subject { described_class.new(context) }

    context 'delete_mapping_rules flag false' do
      let(:context) { { target: target, delete_mapping_rules: false } }
      it 'no op' do
        # Run
        subject.call
      end
    end

    context 'several mapping rules available' do
      let(:context) { { target: target, delete_mapping_rules: true } }
      let(:n_rules) { 10 }
      let(:target_mapping_rules) do
        Array.new(n_rules) do |_|
          instance_double('ThreeScaleToolbox::Entities::MappingRule')
        end
      end

      it 'it calls delete_mapping_rule method on each rule' do
        expect(target).to receive(:mapping_rules).and_return(target_mapping_rules)
        expect(target_mapping_rules.size).to be > 0
        target_mapping_rules.each do |mapping_rule|
          expect(mapping_rule).to receive(:delete)
        end

        # Run
        subject.call
      end
    end
  end
end
